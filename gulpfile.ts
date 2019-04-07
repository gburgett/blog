import gulp from "gulp";
import cp from "child_process";
import gutil from "gulp-util";
import BrowserSync from "browser-sync";
import fs from 'fs-extra';

declare function require(path: string): any;

// import image processing tasks
require('./image_tasks');

// // import search index tasks
// require('hugo-search-index/gulp')(gulp, gutil)

const browserSync = BrowserSync.create();
const hugoBin = "hugo";
const defaultArgs = ["-v"];

/**
 * hugo: runs the hugo binary to build the hugo site.
 *  
 * depends -
 *   css : builds sass & minifies css files, placing the result in static/css/ for hugo to pick it up
 *   js  : builds javascript and bundles it with webpack, placing the bundle in static/js/ for hugo to pick it up
 *   img: the img task processes images in-place in static/images/, 
 *        so it must finish before running hugo.
 */
export const hugo = gulp.series('img', buildHugo);

function buildHugo(cb, options?) {
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
 * clean: deletes hugo build output
 */
export function clean(cb) {
  remove('./public').then(
    () => cb(),
    err => {
      cb(err)
    }
  )
}

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

export const build = hugo
export default build

/**
 * Runs the development server and watches for changes.
 * 
 * Depends:
 *   build - do the normal build process
 */
export const server = gulp.series(build, runServer)

function runServer() {
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
};
