#!/usr/bin/env Rscript
# Bash-ready script for mosaicking Landsat tiles.
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
library(doParallel)
library(tools)
library(raster)
library(optparse)

# Command-line options
parser = OptionParser()
parser = add_option(parser, c("-i", "--input-dir"), type="character", default="../data/satellite",
    help="Root directory (containing subdirectories with names of vegetation indices) of input files. Should have no clouds. (Default: %default)", metavar="path")
parser = add_option(parser, c("-o", "--output-dir"), type="character", metavar="path",
    default="../data/intermediary/cloud-free",
    help="Output directory. Subdirectories for each vegetation index will be created. (Default: %default)")
parser = add_option(parser, c("-p", "--pattern"), type="character", metavar="regex",
    help="Pattern to filter input files on. (Default: %default)", default="*.tif")
parser = add_option(parser, c("-t", "--threads"), type="numeric", default=detectCores()-1,  metavar="num",
    help="Number of threads to use for multicore processing. 1 GiB RAM is required per thread. (Default: %default)")
sink("/dev/null") # Silence rasterOptions
parser = add_option(parser, c("-m", "--temp-dir"), type="character", metavar="path",
    help=paste0("Path to a temporary directory to store results in. (Default: ",
        rasterOptions()$tmpdir, ")"))
sink()
args = parse_args(parser)

source("preprocessing/landsat-mosaic-tiles.r")

if (!is.null(args[["temp-dir"]]))
        rasterOptions(tmpdir=args[["temp-dir"]])

psnice(value = min(args[["threads"]] - 1, 19))
registerDoParallel(cores = args[["threads"]])

LSMosaicVIs(args[["input-dir"]], args[["pattern"]], args[["output-dir"]])
