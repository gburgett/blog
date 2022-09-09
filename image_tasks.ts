import { Transform } from 'stream'
import { execFile } from 'child_process'
import os from 'os'
import path from 'path'

import gulp from 'gulp'
import gutil from 'gulp-util'
import imageResize from 'gulp-image-resize'
import imagemin from 'gulp-imagemin'
import fs from 'fs-extra'
import gifsicle from 'gifsicle'
import debug from 'gulp-debug'

// converts a Vinyl file's path in the src directory (/images/) to the mirror directory (/images/.640x/)
const srcToMirror = file =>
            path.join(path.dirname(file.base), '.640x/' + path.basename(file.base))

// a transform that simply logs every Vinyl file passed to it
/*
const logFiles = new Transform({
  objectMode: true,

  transform (file, encoding, callback) {
    gutil.log('base: ', file.base, 'path: ', file.path, 'cwd: ', file.cwd, 'stat', file.stat)
    callback(null, file)
  }
}) */

// A filter transform that removes from the stream files which are found in the mirror directory
const filterIfCopyExists = (findInMirror) => new Transform({
  objectMode: true,

  transform (file, encoding, callback) {
    var to = path.join(findInMirror(file), file.relative)

    fs.exists(to, exists => {
      if (exists) {
            // this file is already processed - skip it
        callback(null, null)
        return
      }
      callback(null, file)
    })
  }
})

// A filter transform that removes from the stream files which are not the same size as their mirrors
// (meaning they've already been processed)
const filterIfCopyNotSameSize = (findMirror) => new Transform({
  objectMode: true,

  transform (file, encoding, callback) {
    var to = path.join(findMirror(file), file.relative)
    fs.stat(to, (err, stats) => {
      if (err) {
        gutil.log('Error stat-ing: ', err, file.path)
        callback(err, null)
        return
      }
      if (file.stat.size !== stats.size) {
          // the two files are not the same size, filter this out
        callback(null, null)
        return
      }
        // the two files are the same size, pass this to the next transform in the processing chain
      callback(null, file)
    })
  }
})

/**
 * Make the 640x version of the original source images for phones
 */
gulp.task('img-make-640x', () => {
        // note- not processing GIFs due to a problem with gif resizing
  return gulp.src('./static/images/**/*.{jpg,jpeg,png,svg}')
        // filter out files where the copy in the 640x directory has already been processed
      .pipe(filterIfCopyExists(srcToMirror))

        // resize the images from the mirror folder
      .pipe(imageResize({
        width: 640,
        noProfile: true
      }))
      .pipe(imagemin())               // compress the resized images
      .pipe(gulp.dest('./static/.640x/images'))   // write the resized image to the 640x folder
})

/**
 * Optimize gifs into the .640x folder
 */
gulp.task('gif-optimize', () => {
  return gulp.src('./static/images/**/*.gif', { read: false })
        // filter out files where the copy has already been processed
      .pipe(filterIfCopyExists(srcToMirror))

        // optimize the source gif into the correct place
      .pipe(new Transform({
        objectMode: true,

        transform (file, encoding, callback) {
          const toFile = path.join(srcToMirror(file), file.relative)
          fs.ensureDir(path.dirname(toFile), (err) => {
            if (err) {
              gutil.log(gutil.colors.red('[gif] Error making dir') + err)
              callback(err)
              return
            }

            execFile(gifsicle,
              ['--output', toFile, '--resize-width', '640', '--colors', '256', '--optimize=3', file.path],
              (err, stdout, stderr) => {
                if (err) {
                  gutil.log(gutil.colors.red('[gif] gifsicle error:\n') + stderr)
                  callback(err)
                  return
                }
                gutil.log(gutil.colors.dim(stdout))

                callback(null, file)
              }
            )
          })

          
        }
      }))
})

gulp.task('img-clean', (cb) => {
  fs.remove('static/.640x/images', err => {
    if (err) {
      gutil.log('Error cleaning ', path, err.message, err.code, err.errno)
      cb(err)
      return
    }
    cb()
  })
})


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
gulp.task('img', gulp.parallel("img-make-640x", "gif-optimize"))
