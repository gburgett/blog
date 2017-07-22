+++
menu = "main"
title = "Search"
navtitle = "Search"

+++

# Search

<div>
  <form id="searchForm">
    <div class='searchContainer'>
      <i class="fa fa-search" aria-hidden="true" onClick="$('#searchSubmit').click();"></i>
      <input type="search" placeholder="Search..."></input>
      <i id="searchSpinner" class="fa fa-spinner fa-spin" aria-hidden="true"></i>
      <button type="submit" id="searchSubmit" style="display:none;"></button>
    </div>
  </form>
</div>

<div>
  <table id="searchResults">
  </table>
</div>
