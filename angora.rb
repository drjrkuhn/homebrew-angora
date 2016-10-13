class Angora < Formula
  desc "A free finite-difference time-domain (FDTD) electromagnetic simulation package"
  homepage "http://www.angorafdtd.org/"
  url "https://github.com/drjrkuhn/angora/archive/0.20.1.tar.gz"
  version "0.20.1"
  sha256 "3f216809411cb1180e0eb6ad226e2c339647b282aebaf1c686aac26c28b37391"
  head "https://github.com/drjrkuhn/angora.git"

  option "with-gnu", "force compilation with gnu compiler rather than clang"
  if build.with? "gcc"
    fails_with :clang
    fails_with :gcc => "4.6" do
      cause "The only supported compiler is GCC(>=4.7)."
    end
  end

  depends_on :mpi => [:cc, :optional]

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build

  hdf5_args = Array.new
  hdf5_args << "with-mpi" if build.with? "mpi"

  boost_args = Array.new
  boost_args << "with-mpi" if build.with? "mpi"
  boost_args << "without-single" if build.with? "mpi"

  depends_on "hdf5" => hdf5_args
  depends_on "h5utils" => :recommended
  depends_on "blitz"
  depends_on "libconfig"
  depends_on "argp-standalone"
  depends_on "boost" => boost_args
  
  def install
    conf_args = [
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}"
    ]
    conf_args << "--with-mpi" if build.with? "mpi"
    
    ## for testing
    # export CXXFLAGS="-std=c++98 -Wno-parentheses"
    # export CPLUS_INCLUDE_PATH="/usr/local/include"
    # export LIBRARY_PATH="/usr/local/lib"
    # export LIBS="-largp -lhdf5 -lhdf5_cpp -lconfig++"
    # export HDF5_CXX="c++" HDF5_CLINKER="c++"

    ENV.append "CPLUS_INCLUDE_PATH", "#{HOMEBREW_PREFIX}/include"
    ENV.append "LIBRARY_PATH", "#{HOMEBREW_PREFIX}/lib"

    # default /usr/local/include search path
#     ENV.append "CPLUS_INCLUDE_PATH", "-I#{HOMEBREW_PREFIX}/include"
#     ENV.append "LIBRARY_PATH", "-I#{HOMEBREW_PREFIX}/lib"
    # use older C++ standard
    ENV.append "CXXLAGS", " -std=c++98 -Wno-parentheses"
    # force the library dependencies
    ENV.append "LIBS", " -largp -lhdf5 -lhdf5_cpp -lconfig++"
    # do not compile through the h5c++ script
    ENV["HDF5_CXX"] = "g++"
    ENV["HDF5_CLINKER"] = "g++"
    ENV["HDF5_C"] = "gcc"

    system "autoreconf", "-fiv"
    system "./configure", *conf_args
    system "make", "install" # if this fails, try separate make/make install steps
  end

  #test do
  #  system "false"
  #end
end
