import gulp from "gulp";
import cp from "child_process";
import gutil from "gulp-util";
import BrowserSync from "browser-sync";
import fs from 'fs-extra';

// import image processing tasks
require('./image_tasks.babel.js');

// import search index tasks
require('hugo-search-index/gulp')(gulp, gutil)

const browserSync = BrowserSync.create();
const hugoBin = "hugo";
const defaultArgs = ["-v"];

gulp.task("default", ["build"]);

gulp.task("build", ["hugo", "search"]);

/**
 * hugo: runs the hugo binary to build the hugo site.
 *  
 * depends -
 *   css : builds sass & minifies css files, placing the result in static/css/ for hugo to pick it up
 *   js  : builds javascript and bundles it with webpack, placing the bundle in static/js/ for hugo to pick it up
 *   img: the img task processes images in-place in static/images/, 
 *        so it must finish before running hugo.
 */
gulp.task("hugo", ["img"], (cb) => buildHugo(cb));


function buildHugo(cb, options) {
  const args = options ? defaultArgs.concat(options) : defaultArgs;

  return cp.spawn(hugoBin, args, {stdio: "inherit"}).on("close", (code) => {
    if (code === 0) {
      cb();
    } else {
      cb("Hugo build failed");
    }
  });
}

/**
 * clean-hugo: deletes hugo build output
 */
gulp.task("clean-hugo", (cb) => {
  remove('./public', cb).then(
    () => cb(),
    err => {
      cb(err)
    }
  )
})

gulp.task("clean", ["clean-hugo"])



/** deletes the given directory, returning a promise that completes when deletion finishes */
function remove(path) {
  var errors = []

  return new Promise((resolve, reject) => {
    fs.remove(path, err => {
      if (err) {
        gutil.log('Error cleaning ', path, err.message, err.code, err.errno)
        reject(err)
        return
      }
      resolve()
    })
  })
  
}

/**
 * img: Processes images in-place in the static/images/ folder.
 *      Images are resized to a max width of 640x and compressed to save
 *      bandwidth.  Includes checks so it will do nothing if images are already
 *      processed.  Tasks loaded from './gulp_image_tasks.babel.js'
 * 
 *      Images in both the 'images/' and 'images.original/' folder should be
 *      checked in to git in order to reduce the image processing work that has
 *      to be done on builds.
 * 
 * depends -
 *   img-mirror: copies any new images from 'images/' to '.original-images' to save the originals
 *   img-make-640x: resizes and compresses images from '.original-images' over their equivalent in 'images/'
 *   gif-optimize: resizes and compresses gifs from '.original-images' over their equivalent in 'images/'
 */
gulp.task("img", ["img-make-640x", "gif-optimize"]);

/**
 * Runs the development server and watches for changes.
 * 
 * Depends:
 *   build - do the normal build process
 */
gulp.task("server", ["build"], () => {
  browserSync.init({
    server: {
      baseDir: "./public"
    }
  });
  gulp.watch([        //all the hugo directories
    "archetypes/**/*.*",
    "content/**/*.*",
    "data/**/*.*",
    "layouts/**/*.*",
    "static/*.*",                   // files in the root of 'static/'
    "static/!(generated-*)/**/*.*", // files deeper in 'static/' but not in 'generated-' (taken care of by the above watches)
    "themes/**/*.*",
    "config.toml"
  ], () => {
    browserSync.notify("rebuilding hugo...")
    buildHugo(err => {
      if(err){
        gutil.log(gutil.colors.red('[hugo] Error building hugo: ') + err)
        browserSync.notify("Hugo build failed :(");
      } else {
        browserSync.reload();
      }
    })
  });
});
