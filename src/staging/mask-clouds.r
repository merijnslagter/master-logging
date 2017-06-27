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


# Input: Directory with input Landsat images, or a list of files; directory with FMask outputs, or a list of files;
#        output directory.
# Output: Landsat images with all clouded areas set to NA.

# NOTE: Due to the big data nature, we can't process everything at once, this needs to be done in batches.
# Therefore the script first checks if the output files already exist, if not, processes the input.
# That avoids the problem of mixing different batches together.
# It also optionally removes the input data to save disk space after processing is deemed successful.

# NOTE: Requires a new enough version of bfastSpatial that can handle Landsat Collection 1 data (-dev at the moment)
library(bfastSpatial)
library(optparse)

# Command-line options
parser = OptionParser()
parser = add_option(parser, c("-i", "--input-dir"), type="character", default="../data/satellite",
    help="Directory of input files. May be compressed. (Default: %default)", metavar="path")
parser = add_option(parser, c("-o", "--output-dir"), type="character", metavar="path",
    default="../data/intermediary/cloud-free",
    help="Output directory. Subdirectories for each vegetation index will be created. (Default: %default)")
parser = add_option(parser, c("-t", "--file-type"), type="character", metavar="extension",
    default="tif",
    help="Output file type. grd is native uncompressed, tif is lightly compresssed. (Default: %default)")
parser = add_option(parser, c("-f", "--filter-pattern"), type="character", metavar="regex",
    help="Pattern to filter input files on.")
args = parse_args(parser)

MaskClouds = function(input_dir=args[["input-dir"]], output_dir=args[["output-dir"]],
    file_type=args[["file-type"]], filter_pattern=args[["filter-pattern"]], ...)
{
    
    # Keep=c(0:223, 225:255) for nbr since it seems to be able to deal with shadows
    processLandsatBatch(x=input_dir, outdir=output_dir, fileExt=file_type, mask="pixel_qa", keep=66,
        vi=c("ndvi", "evi", "msavi", "nbr", "ndmi"), delete=TRUE, pattern=filter_pattern, ...)
}

rasterOptions(tmpdir="/userdata2/tmp/")
processLandsat("../data/satellite/peru/LE072310562009061401T2-SC20170623194824.tar.gz",
    "../data/intermediary/cloud-free/peru", c("ndvi", "evi", "msavi", "nbr", "ndmi"), delete=TRUE,
    mask="pixel_qa", keep=66, fileExt="tif")
# The result is fine but the compression is poor. We can do better with
# COMPRESS=DEFLATE ZLEVEL=9 SPARSE_OK=TRUE NUM_THREADS=4, so maybe run without compression first
