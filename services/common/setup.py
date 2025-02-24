from setuptools import setup, find_packages

setup(
    name="ai_coding_bench_common",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "pydantic>=2.5.2",
        "python-jose[cryptography]>=3.3.0",
        "passlib[bcrypt]>=1.7.4",
        "python-dotenv>=1.0.0",
        "structlog>=23.2.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.4.3",
            "black>=23.11.0",
            "pylint>=3.0.2",
            "mypy>=1.7.1",
        ]
    },
    python_requires=">=3.8",
    author="Your Organization",
    author_email="your.email@example.com",
    description="Common utilities for AI Coding Bench services",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/your-org/ai-coding-bench-common",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3.8",
    ],
) 