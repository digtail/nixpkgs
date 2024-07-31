{ lib
, stdenv
, fetchFromGitLab
, fetchpatch

# build time
, bison
, docbook_xsl
, docutils
, flex
, gtk-doc
, meson
, ninja
, pkg-config
, utilmacros

# runtime
, alsa-lib
, cairo
, curl
, elfutils
, glib
, gsl
, json_c
, kmod
, libdrm
, liboping
, libpciaccess
, libunwind
, libX11
, libXext
, libXrandr
, libXv
, openssl
, peg
, procps
, python3
, udev
, valgrind
, xmlrpc_c
, xorgproto
}:

stdenv.mkDerivation rec {
  pname = "intel-gpu-tools";
  version = "1.28";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "drm";
    repo = "igt-gpu-tools";
    rev = "v${version}";
    hash = "sha256-tSI6cX9HXJlRbRqtYJRL6AUBFuhfDv9FnpK0S//Ttpb=";
  };

  patches = [
    # fixes pkgsMusl.intel-gpu-tools
    # https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/issues/138

    (fetchpatch {
      url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/commit/c37512dc61a753264ff3b812f79235abe62de8ab.patch";
      hash = "sha256-0o2CrofCAIyebrglxCOGl4re6EeVDUzPLZ4S9eg80iQ=";
    })
    (fetchpatch {
      url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/commit/02bd39fe6ff205abf3bf31389c4d2835ec3f9b7b.patch";
      hash = "sha256-suq+eu5aIgTVr2iP86lloePoSJjya3qNiWtRiEms32Y=";
    })
    (fetchpatch {
      url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/commit/3f00ba1670b7ab8cfa068ece29f33fd50575aeac.patch";
      hash = "sha256-1fR44kbYDaKMEGl5O9rGZ5sYgbzNpu1GS2qNRoN5O94=";
    })

    (fetchpatch {
      url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/commit/d48f4a2ad2d524b0ac4d5b8208553a0ec739cf2b.patch";
      hash = "sha256-mmF/pnFGA9h8KWFuBXJvO9mC/e79gjNZp5W2/uja1bo=";
    })
    (fetchpatch {
      url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/commit/0571a65a21fcfc3b5fb0e6004e0ee8bc7539cafc.patch";
      hash = "sha256-CIwl1jdJQdpfNnAVWok4QUAqMcHU9PSP6iZ6UoRp90o=";
    })
    (fetchpatch {
      url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/commit/8957935a098628b65b53878c5829b08da6eb1f5a.patch";
      hash = "sha256-Hal/EPK0LN1NNyy/h5MdHrVMFGquZRStYQwzLyaPcYE=";
    })
    (fetchpatch {
      url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/commit/ca55d486b97e3490f1dc331966f724332e80958c.patch";
      hash = "sha256-EiOhNbD6Wk4nhg24PUTOEmaaaCANnnz0+h4xGEIxnVs=";
    })
    (fetchpatch {
      url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/commit/e8678d9f32e08f423c5a073b325d4051934ab48c.patch";
      hash = "sha256-6FskbpGNyE4lSQonV2t9AO5emVgrYq2ZXhob8CXoe8U=";
    })
  ];

  nativeBuildInputs = [
    bison
    docbook_xsl
    docutils
    flex
    gtk-doc
    meson
    ninja
    pkg-config
    utilmacros
  ];

  buildInputs = [
    alsa-lib
    cairo
    curl
    elfutils
    glib
    gsl
    json_c
    kmod
    libdrm
    liboping
    libpciaccess
    libunwind
    libX11
    libXext
    libXrandr
    libXv
    openssl
    peg
    procps
    python3
    udev
    valgrind
    xmlrpc_c
    xorgproto
  ];

  preConfigure = ''
    patchShebangs tests man scripts
  '';

  hardeningDisable = [ "bindnow" ];

  # We have a symbol conflict of PAGE_SIZE defined by fortify-headers and PAGE_SIZE
  # defined in kms_atomic.c. We rename the PAGE_SIZE in kms_atomic.c in order to work
  # around the conflict so that we can continue using the fortify hardening.
  # This is not really upstreamable, because it only happens when using fortify-headers.
  postPatch = ''
    sed "s/ PAGE_SIZE/ page_size/g" -i tests/kms_atomic.c
  '';

  meta = with lib; {
    changelog = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/blob/v${version}/NEWS";
    homepage = "https://drm.pages.freedesktop.org/igt-gpu-tools/";
    description = "Tools for development and testing of the Intel DRM driver";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = with maintainers; [ pSub ];
  };
}
