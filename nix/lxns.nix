{
  buildPythonPackage,
  fetchFromGitHub,
  meson-python,
}:

buildPythonPackage rec {
  pname = "lxns";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "igo95862";
    repo = "python-lxns";
    rev = version;
    hash = "sha256-O7B2Do+b70i00HDxWgIV1yuNIx5lmpoZmHeA6yS2nLY=";
  };

  build-system = [
    meson-python
  ];

  pythonImportsCheck = [
    "lxns"
  ];
}
