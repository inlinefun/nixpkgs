{
  lib,
  stdenv,
  replaceVars,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  joblib,
  segments,
  attrs,
  dlinfo,
  typing-extensions,
  espeak-ng,
  setuptools,
  pytest,
}:

buildPythonPackage rec {
  pname = "phonemizer";
  version = "3.3.0";
  pyproject = true;

  build-system = [ setuptools ];

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Xgw4Ei7/4LMxok5nSv8laHTs4WnXCpzxEgM3tW+OPQw=";
  };

  patches = [
    (replaceVars ./backend-paths.patch {
      libespeak = "${lib.getLib espeak-ng}/lib/libespeak-ng${stdenv.hostPlatform.extensions.sharedLibrary}";
      # FIXME package festival
    })
    # This patch is needed for python3Packages.misaki. See https://github.com/thewh1teagle/espeakng-loader?tab=readme-ov-file#usage-with-phonemizer.
    (fetchpatch {
      name = "pr191-add-option-to-use-custom-espeak-data-path.patch";
      url = "https://github.com/bootphon/phonemizer/commit/cc1db4bfaf688fdfb8275fd83d218f06411455e6.patch";
      hash = "sha256-9TEEBmLrYU5Ftjclr1UBwA42sef7+4ToGACN/MrB86w=";
    })
  ];

  propagatedBuildInputs = [
    joblib
    segments
    attrs
    dlinfo
    typing-extensions
  ];

  # We tried to package festival, but were unable to get the backend running,
  # so let's disable related tests.
  doCheck = false;

  meta = {
    homepage = "https://github.com/bootphon/phonemizer";
    changelog = "https://github.com/bootphon/phonemizer/blob/v${version}/CHANGELOG.md";
    description = "Simple text to phones converter for multiple languages";
    mainProgram = "phonemize";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
  };
}
