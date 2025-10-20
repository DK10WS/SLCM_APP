import nox


@nox.session
def lint(session, venv_backend="uv"):
    session.run(
        "uv",
        "sync",
        "--active",
        "--locked",
        "--inexact",
    )

    session.run("pyrefly", "check", "src/")
    session.run("ruff", "format", "src/")
    session.run("ruff", "check", "src/")
