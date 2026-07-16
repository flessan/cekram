from setuptools import setup, find_packages

setup(
    name="cekram",
    version="1.0.0",
    author="flessan",
    description="Universal Super RAM Monitor & Auto-Purge (Multi-Platform, Multi-Language ID/EN)",
    long_description=open("../README.md", "r", encoding="utf-8").read() if open("../README.md", "r", encoding="utf-8") else "",
    long_description_content_type="text/markdown",
    url="https://github.com/flessan/cekram",
    packages=find_packages(),
    entry_points={
        "console_scripts": [
            "cekram=cekram.cli:main",
        ],
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
    extras_require={
        "full": ["psutil>=5.8.0"],
    },
)
