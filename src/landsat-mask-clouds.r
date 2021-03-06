#!/usr/bin/env Rscript
# Masks clouds in Landsat imagery by applying FMask output to images.
#
# Copyright (C) 2017  Dainius Masiliunas
#
# This file is part of the selective logging detection through time series thesis.
#
# Scripts of the thesis are free software: you can redistribute them and/or modify
# them under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# The scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the scripts.  If not, see <http://www.gnu.org/licenses/>.

library(parallel)
library(raster)
library(optparse)

# Command-line options
parser = OptionParser()
parser = add_option(parser, c("-i", "--input-dir"), type="character", default="../data/satellite",
    help="Directory of input files. May be compressed. (Default: %default)", metavar="path")
parser = add_option(parser, c("-o", "--output-dir"), type="character", metavar="path",
    default="../data/intermediary/cloud-free",
    help="Output directory. Subdirectories for each vegetation index will be created. (Default: %default)")
parser = add_option(parser, c("-e", "--file-type"), type="character", metavar="extension", default="grd",
    help="Output file type. grd is native uncompressed, tif is lightly compresssed. (Default: %default)")
parser = add_option(parser, c("-p", "--pattern"), type="character", metavar="regex",
    help="Pattern to filter input files on. Should not include the extension (end with a *).")
parser = add_option(parser, c("-t", "--threads"), type="numeric", default=detectCores()-1,  metavar="num",
    help="Number of threads to use for multicore processing. (Default: %default)")
parser = add_option(parser, c("-r", "--memory"), type="numeric", default=3,  metavar="num",
    help="Maximum RAM consumption per thread, in GiB. raster defaults use 1.6 GiB RAM per thread, but increasing it is highly beneficial (Default: %default)")
sink("/dev/null") # Silence rasterOptions
parser = add_option(parser, c("-m", "--temp-dir"), type="character", metavar="path",
    help=paste0("Path to a temporary directory to store results in. (Default: ",
        rasterOptions()$tmpdir, ")"))
sink()
args = parse_args(parser)

source("preprocessing/landsat-mask-clouds.r")

if (!is.null(args[["temp-dir"]]))
        rasterOptions(tmpdir=args[["temp-dir"]])
MemoryInCells = args[["memory"]]*1024*1024*1024/16
rasterOptions(maxmemory=MemoryInCells, chunksize=MemoryInCells/4)

MaskClouds(args[["input-dir"]], args[["output-dir"]], args[["file-type"]], args[["pattern"]], args[["threads"]])

# Could keep=c(0:223, 225:255) for nbr since it seems to be able to deal with shadows (or maybe that makes NBR higher)
