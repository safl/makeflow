import makeflow

def test_project_has_version():

    assert getattr(makeflow, "__version__")

def test_true():

    assert True