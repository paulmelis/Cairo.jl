using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libcairo"], :libcairo),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Cairo_jll.jl/releases/download/Cairo-v1.14.12+4"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Cairo.v1.14.12.aarch64-linux-gnu.tar.gz", "415b421457c08ee29e9c2b98e3efccae7e5743f940343bb3f02dd7ead84a2464"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Cairo.v1.14.12.aarch64-linux-musl.tar.gz", "ed5edba23f3538c000730f322baa9e718dfd08440cfff6f11a5d73588449e63a"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Cairo.v1.14.12.arm-linux-gnueabihf.tar.gz", "7da134f916a7e35755a5ef5d1555cd896e3afeb0d6e2ee127e147b9315773122"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Cairo.v1.14.12.arm-linux-musleabihf.tar.gz", "41fa67217ffcb102120181e06f0555a308eaa7011a9cd1eb726d1df7b57eb0ba"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Cairo.v1.14.12.i686-linux-gnu.tar.gz", "eda89f0daefc59865e34d3b6cd9a79e2beceeda09e84c07de8137ea7f8917396"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Cairo.v1.14.12.i686-linux-musl.tar.gz", "9f4264755753cfe9fee249767a6b51fd5c2254e956bd7f9befd96ff2f25fc81a"),
    Windows(:i686) => ("$bin_prefix/Cairo.v1.14.12.i686-w64-mingw32.tar.gz", "c912dd8c45d1e604bba5307a61dfdecc91fc7ff0097bd60b024b74f59764ff6d"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Cairo.v1.14.12.powerpc64le-linux-gnu.tar.gz", "513c6a27d92394a35d2cdc932806ff00a8acf1d11f211541109fde8ef38bfaa7"),
    MacOS(:x86_64) => ("$bin_prefix/Cairo.v1.14.12.x86_64-apple-darwin14.tar.gz", "73cb413e35aa3e6d50a835513ed96ab46ef4d996fb54e6c870a63884fc272a7a"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Cairo.v1.14.12.x86_64-linux-gnu.tar.gz", "9b6a4fc260289be54ff6b38cbed19a035a7ee874ab9c41a1b172700a502c248f"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Cairo.v1.14.12.x86_64-linux-musl.tar.gz", "1aea54bc6d7cb46ab702e442c1b952c09b7a231ebd5bf6cc61f6f6236097a74b"),
    FreeBSD(:x86_64) => ("$bin_prefix/Cairo.v1.14.12.x86_64-unknown-freebsd11.1.tar.gz", "0762814b23a80e6f87fb0db7549f9853ae9d4547c6a2d28d0489e3bd31bb04e4"),
    Windows(:x86_64) => ("$bin_prefix/Cairo.v1.14.12.x86_64-w64-mingw32.tar.gz", "115a8dbc03669c0135ff7187ac779d00f17cd50c42327d7cbf21714dc1f62e17"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)