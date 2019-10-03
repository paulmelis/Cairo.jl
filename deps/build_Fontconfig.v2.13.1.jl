using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libfontconfig"], :libfontconfig),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Fontconfig_jll.jl/releases/download/Fontconfig-v2.13.1+4"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Fontconfig.v2.13.1.aarch64-linux-gnu.tar.gz", "ce3c8ea36231e5dcdbd71d96c654f97eb1fb5f8e7a4b7951e55999c7699ab108"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Fontconfig.v2.13.1.aarch64-linux-musl.tar.gz", "1bfe11f61556b7f26db16cafbccf1d89c2f782b1a0d41317b568eaed6276b2d0"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Fontconfig.v2.13.1.arm-linux-gnueabihf.tar.gz", "ead1d8207e6977597fadd0fe6ad786a11f77f7aab5d30ff9c4335d80d26ff84c"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Fontconfig.v2.13.1.arm-linux-musleabihf.tar.gz", "08c440433f941b836792f963d89e7f83196838b0551012a689dadfad27bc053b"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Fontconfig.v2.13.1.i686-linux-gnu.tar.gz", "6668ec0b363c2cc4bfda390f49cd36e94065b24f4b623223fd727099be71eb07"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Fontconfig.v2.13.1.i686-linux-musl.tar.gz", "f8d4142ba05652301c52e364babbd6f318868c8e42c84bbaa24be3512e887e2c"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Fontconfig.v2.13.1.powerpc64le-linux-gnu.tar.gz", "27b7b0bfa274e62d19e0e96b0af2caca60c56579b2d2d6b86f13411a8805881b"),
    MacOS(:x86_64) => ("$bin_prefix/Fontconfig.v2.13.1.x86_64-apple-darwin14.tar.gz", "fa7b75c808fd358fca1d70242a471e9c302f569c2093eb7b683dd7f09c148ff0"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Fontconfig.v2.13.1.x86_64-linux-gnu.tar.gz", "2cc769abdcc16006c576dba061eb850bde37a192093764743f4acd227342a915"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Fontconfig.v2.13.1.x86_64-linux-musl.tar.gz", "a13e96078c60882d6f86356b3b514f94d490b783fc7bb5118eda0eb17e614cae"),
    FreeBSD(:x86_64) => ("$bin_prefix/Fontconfig.v2.13.1.x86_64-unknown-freebsd11.1.tar.gz", "1dcd862db04758bff6b60c6f38553e846551f66ca22743d9ea8e3a23ee3433e9"),
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