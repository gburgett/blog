+++
title = "Feeling Like I'm at Hogwarts"
Description = ""
Tags = ["javascript", "development", "typescript"]
Categories = ["development"]
menu = "main"
date = 2018-05-20T14:52:15-05:00
+++

I spent some time this week playing with [Typescript 2.8's new features](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-8.html)
for modeling various complex types.  The new syntax that I wanted to play with
was the conditional type syntax,
```ts
T extends U ? X : Y
```

This syntax allows you to express some really crazy type relationships!  Some of
the most interesting ones have been pre-defined in the Typescript standard lib:

* `Exclude<T, U>` – Exclude from T those types that are assignable to U.
* `Extract<T, U>` – Extract from T those types that are assignable to U.

I wanted to see if I could use these to model the way we've been working with
return values from [Contentful's Content Delivery API](https://www.contentful.com/developers/docs/references/content-delivery-api/).

[Skip to the final type definitions -->](#going-recursive)

## Modeling a CDN API response

We can break up the raw response into several re-usable sections.  First, all links
have a common structure that we can model with an `ILink` type:

```json
{
  "sys": {
    "type": "Link",
    "linkType": "Entry",
    "id": "0SUbYs2vZlXjVR6bH6o83O"
  }
}
```
```ts
export interface ILink<Type extends string> {
  sys: {
    type: 'Link',
    linkType: Type,
    id: string,
  },
}
```
Notice that the ILink is generic over the LinkType.  This lets us have a
`ILink<'Entry'>` and an `ILink<'Space'>`, which cannot be assigned to eachother.
This reflects all the kinds of links that can exist in a response.

Next let's wrap up the entry Sys field in its own interface:

```ts
export interface ISys<Type extends string> {
  space: ILink<'Space'>,
  id: string,
  type: Type,
  createdAt?: string,
  updatedAt?: string,
  revision?: number,
  environment?: ILink<'Environment'>,
  contentType: ILink<'ContentType'>,
  locale?: string,
}
```
ISys is also generic over the type, so an `ISys<'Entry'>` and `ISys<'Asset'>` are
not compatible.

Now we can define an Entry:
```ts
export interface IEntry<TFields> {
  sys: ISys<'Entry'>,
  fields: TFields
}
```

and an Asset:
```ts
export interface IAsset {
  sys: ISys<'Asset'>,
  fields: {
    // TODO: more fields for different asset types
    title?: string,
    description?: string,
    file: {
      url?: string,
      details?: {
        size?: number,
      },
      fileName?: string,
      contentType?: string,
    },
  }
}
```

This construction allows us to define Typescript interfaces for our content types
by simply defining their fields, without duplicating the Sys object definition:

```ts
export interface IPageProps {
  title: string
  slug: string
  parent: ILink<'Entry'>
  sections?: Array<ILink<'Entry'>>
  subpages?: Array<ILink<'Entry'>>
}

export interface IPage extends IEntry<IPageProps> {}

export function isPage(entry: IEntry<any>): entry is IPage {
  return entry &&
    entry.sys &&
    entry.sys.contentType &&
    entry.sys.contentType.sys &&
    entry.sys.contentType.sys.id == 'page'
}
```

I love having intellisense pop up to help me see the fields on an entry!
![Intellisense on an entry](/images/2018/05_entry_intellisense.jpg)

## Resolving links

Now I have a problem though, because I want to take a link to a section and then
download the actual section object in order to render it.  One way to do that
is to wrap a function around the API that resolves my links:

```ts
export function resolve<TLink>(link: ILink<TLink>): IEntry<any> {
  // hit the API here
}
```
But ideally, I'd like to be able to just resolve my tree of objects once using
something like [the `include` parameter](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/links/retrieval-of-linked-items)
and then replace links in my object structure with the actual resolved entry.
The implementation of this is not too difficult - and less interesting.  What's
more interesting is modeling the types.  My goal is to be able to do something
ridiculous like this:

```ts
const thumbUrl =
  page.fields.parent.fields.sections[0].fields.header.fields.thumbnail.fields.file.url
```

Defining the types to be able to do this in an elegant way is going to take some
magic.  So let's take a trip to Hogwarts :)

First, let's reflect the fact that my Page can have links that are either resolved
or not, and define the allowable types that they can resolve to:

```ts
export interface IPageProps {
  title: string
  slug: string
  parent: ILink<'Entry'> | IPage
  sections?: Array<ILink<'Entry'> | PageSection>
  subpages?: Array<ILink<'Entry'> | IPage>
}

// this is all the content types that can be assigned to the Sections array.
export type PageSection = ISectionHeader | ISectionBlockText | ...
```

This gets me part-way there.  Now instead of calling `resolve` to hit the API
every time I want to access a section, I can just cast it.  Or, to get some runtime
protection, I can create a method `expectResolved` to early-exit if it's still a link:

```ts
function expectResolved<T>(prop: T): Exclude<T, ILink<any>> {
  if (isLink(prop)) {
    throw new Error(`Expect ${prop.sys.id} to have been resolved but was still a link.`)
  }
  return prop
}
```
usage:

```jsx
  public render() {
    const { title, sections } = this.props.page.fields

    return <div>
      <h1>{title}</h1>
      {sections.map((s) => this.renderSection(expectResolved(s)))}
    </div>
  }

  private renderSection(s: PageSection) {
```

But this doesn't satisfy me.  This is some Ron Weasley code.  What would Hermione do?

## Enter the magic

I know I can recursively resolve my entire tree at runtime, but can I recursively
modify the type definitions in order to tell Typescript that `ILink` is never
going to be present in these props?  I certainly don't want to maintain two
versions of `IPage`.  That would be a pain.  I'd ideally like a generic type
`Resolved<T>` such that `Resolved<IPage>` says there are no links in the fields,
and no links in the fields of those linked fields.  This'll enable my desired
result:
```ts
const page: Resolved<IPage> = ...
const thumbUrl =
  page.fields.parent.fields.sections[0].fields.header.fields.thumbnail.fields.file.url
```

Fortunately Typescript 2.8 just introduced a new form of magic - the conditional
type defs!  Using those together with the `infer` keyword, I can basically use
if statements and assign variables inside a typedef!

So let's go top-down.  Supposing I have an `IEntry<ISomeFields>`, I want to transform
`ISomeFields` such that `ILink<any>` does not appear in any of its properties.

```typescript
export type Resolved<TEntry> =
  TEntry extends IEntry<infer TProps> ?
    // TEntry is an entry and we know the type of it's props
    IEntry<{
      [P in keyof TProps]: ... // Transform the values of these props
    }>
    // Compiler should validate that TEntry is never not an entry
    : never
```

Now we're down into the weeds of this spell.  We have access to the type of each
property in the entry's `fields` via `TProps[P]`.  If the field `name` is a string,
then `TProps['name'] == string`.  If the field `parent` is an `ILink<'Entry'> | IPage`,
how do we get it to be just an `IPage`?  `Exclude` does the trick:
```ts
  [P in keyof TProps]: Exclude<TProps[P], ILink<any>>
```

Alrighty, now we've got `parent` working.  We also get assets for free, since
`ILink<'Asset'> | IAsset` becomes just `IAsset`.  Time to go deeper.  We need to
handle Arrays.  Let's define a new type:

```ts
type ResolvedArray<TItem> = Array<Exclude<TItem, ILink<any>>>
```
And a wrapper type that checks if the field is an array:
```ts
type ResolvedField<TField> =
    TField extends Array<infer TItem> ?
      // Array of entries - dive into the item type to remove links
      ResolvedArray<TItem> :
      TField
```
Then we use that in our properties declaration:
```ts
  [P in keyof TProps]: ResolvedField<Exclude<TProps[P], ILink<any>>>
```
Now we've got a type that wraps any `IEntry`, conforming to the IEntry interface
and none of it's properties are links!  So we can do this:

```ts
const page: Resolved<IPage> = ...
const headerSection = page.fields.parent.fields.sections[0]
// headerSection is `ILink<'Entry'> | PageSection`
```
but we can't recursively dig deeper.  Yet :)

## Going recursive

In Harry Potter, Dumbledore gives Hermione a Time-Turner, which can rewind time
allowing her to get to all her classes and finish her homework every night.

![Hermione's time turner](/images/2018/05_hermione_time_turner.jpg)

That's the kind of power that recursion gives us!  Thanks to Typescript 2.8, we
can go recursive in type definitions as well, building a type definition that
recursively modifies properties all the way down the tree!  All we have to do
is find every spot in our typedef that could be an entry, and if it is, wrap it
in a `Resolved<>`.

```ts
type ResolvedField<TField> =
  // three cases - an Entry which we recursively declare resolved,
  //  an Array which we recursively declare resolved,
  //  or a normal field which we declare to not have links.
  TField extends IEntry<infer TProps> ?
    // Single entry link, recursively declare it resolved.
    Resolved<TField> :
    TField extends Array<infer TItem> ?
      // Array of entries - dive into the item type to remove links
      ResolvedArray<TItem> :
      // Some other type that doesn't need recursive resolution -
      //  declare it has no links and be done
      TField

type ResolvedArray<TItem> =
  TItem extends IEntry<any> ?
      // Entries must be recursively resolved.
    Array<Resolved<TItem>> :
    Array<Exclude<TItem, ILink<any>>>

export type Resolved<TEntry> =
  TEntry extends IEntry<infer TProps> ?
    // TEntry is an entry and we know the type of it's props
    IEntry<{
      [P in keyof TProps]: ResolvedField<Exclude<TProps[P], ILink<any>>>
    }>
    // Compiler should validate that TEntry is never not an entry
    : never
```

I found it!  I found the incantation which lets me magically declare all fields
as resolved all the way down the tree!

## Application

This has real-life uses for our new app at Watermark Community Church.  We have
a tree of available downloads wrapped in nested categories, which we display using
react components on a single page.  We pull this tree from Contentful, recursively
grabbing all the objects in the tree and building out the tree structure in a way
that looks like the above type definitions.  Then we write that JSON out to the
page, where our React components pick it up.

The top-level react component accepts a `Resolved<IResourceTree>` in the props,
and thus it no longer has to worry about whether a node on the tree contains
the actual values, or needs to be resolved.  That's asserted by Typescript -
you can't assign an `IResourceTree` directly to the properties, you have to
wrap it in `expectResolved()` which performs the runtime validation.

I'm really enjoying the expressive power of the typescript type system, and it's
ability to catch errors you didn't even think to write tests for!
