from huggingface_hub import hf_hub_download
import argparse
import os


def symlink_model(data_dir, model_path):
    # Creating a symbolic link from destination to "model.bin"
    model_bin = os.path.join(data_dir, "model.bin")
    if os.path.isfile(model_bin):
        os.remove(model_bin)  # remove the existing link if any
    os.symlink(model_path, model_bin)


def main():
    # Create an argument parser
    parser = argparse.ArgumentParser(description="Process some parameters.")

    parser.add_argument(
        "-m",
        "--model",
        type=str,
        default="TheBloke/openchat-3.5-0106-GGUF",
        help="HuggingFace gguf model.",
    )

    parser.add_argument(
        "-f",
        "--filename",
        type=str,
        default="*.gguf",
        help="HuggingFace model filename",
    )
    parser.add_argument(
        "-d",
        "--datadir",
        type=str,
        default="/data",
        help="Data directory to store HuggingFace models",
    )

    # Parse the arguments
    args = parser.parse_args()

    # Download the model
    dest = hf_hub_download(
        repo_id=args.model,
        filename=args.filename,
        cache_dir=args.datadir,
    )

    # Creating a symbolic link from destination to "model.bin"
    symlink_model(args.datadir, dest)


if __name__ == "__main__":
    main()
