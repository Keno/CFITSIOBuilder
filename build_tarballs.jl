using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
  BinaryProvider.Linux(:x86_64, :glibc),
  BinaryProvider.Linux(:aarch64, :glibc),
  BinaryProvider.Linux(:armv7l, :glibc),
  BinaryProvider.Linux(:powerpc64le, :glibc),
  BinaryProvider.MacOS(),
  BinaryProvider.Windows(:i686),
  BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build cfitsio
sources = [
    "http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3420.tar.gz" =>
    "6c10aa636118fa12d9a5e2e66f22c6436fb358da2af6dbf7e133c142e2ac16b8",
]

script = raw"""
cd $WORKSPACE/srcdir
curl https://heasarc.gsfc.nasa.gov/docs/software/fitsio/cfileio.c > cfitsio/cfileio.c
cd cfitsio/
./configure --prefix=/ --host=$target --enable-reentrant
make -j10 shared
make -e install

"""

products = prefix -> [
    LibraryProduct(prefix,"libcfitsio")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "cfitsio", platforms, sources, script, products)

if !isempty(get(ENV,"TRAVIS_TAG",""))
    print_buildjl(pwd(), products, hashes,
        "https://github.com/Keno/CFITSIOBuilder/releases/download/$(ENV["TRAVIS_TAG"])")
end

