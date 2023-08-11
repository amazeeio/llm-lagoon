import requests
import json
import os
import struct
import argparse

def symlink_model(data_dir, model_path):
    # Creating a symbolic link from destination to "model.bin"
    data_dir = '.'
    model_bin = os.path.join(data_dir, "model.bin")
    if os.path.isfile(model_bin):
        os.remove(model_bin)  # remove the existing link if any
    os.symlink(model_path, model_bin)

def make_request(url, params=None):
    print(f"Making request to {url}...")
    response = requests.get(url, params=params)
    if response.status_code == 200:
        return json.loads(response.text)
    else:
        print(f"Request failed with status code {response.status_code}")
        return None

def check_magic_and_version(filename):
    with open(filename, 'rb') as f:
        # Read the first 6 bytes from the file
        data = f.read(6)

    # Unpack the binary data, interpreting the first 4 bytes as a little-endian unsigned int
    # and the next 2 bytes as a little-endian unsigned short
    magic, version = struct.unpack('<I H', data)

    print(f"magic: 0x{magic:08x}, version: 0x{version:04x}, file: {filename}")

    # print the filesize of the moden in GB way and the permissions
    print(f"File size: {os.path.getsize(filename) / 1024 / 1024 / 1024:.2f} GB")
    print(f"File permissions: {oct(os.stat(filename).st_mode)[-3:]}")

    return magic, version

def download_file(url, destination, params):
    print(f"Downloading {url} to {destination}...")
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(destination, 'wb') as f:
            total_downloaded = 0
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:  # filter out keep-alive new chunks
                    f.write(chunk)
                    total_downloaded += len(chunk)
                    if total_downloaded >= 10485760:  # 10 MB
                        print('.', end='', flush=True)
                        total_downloaded = 0
        print("\nDownload complete.")
        
        symlink_model(params['datadir'], destination)
    else:
        print(f"Download failed with status code {response.status_code}")

def get_user_choice(model_list):
    # Print the enumerated list
    print("\n")
    for i, (model_id, rfilename) in enumerate(model_list):
        print(f"{i+1}: Model ID: {model_id}, RFilename: {rfilename}")

    # Get user's choice
    choice = input("Choose a model to download by entering the corresponding number: ")
    try:
        index = int(choice) - 1
        if 0 <= index < len(model_list):
            # Return the chosen model
            return model_list[index]
        else:
            print("Invalid choice.")
    except ValueError:
        print("Invalid input. Please enter a number corresponding to a model.")
    except IndexError:
        print("Invalid choice. Index out of range.")
    
    return None

def main():
    # Create an argument parser
    parser = argparse.ArgumentParser(description='Process some parameters.')

    # Arguments
    parser.add_argument('-v', '--version', type=int, default=0x0003,
                        help='hexadecimal version number of ggml file')
    parser.add_argument('-a', '--author', type=str, default='TheBloke',
                        help='HuggingFace author filter')
    parser.add_argument('-t', '--tag', type=str, default='llama',
                        help='HuggingFace tag filter')
    parser.add_argument('-s', '--search', type=str, default='',
                        help='HuggingFace search filter')
    parser.add_argument('-f', '--filename', type=str, default='q5_1',
                        help='HuggingFace model repository filename substring match')
    parser.add_argument('-d', '--datadir', type=str, default='/data',
                        help='Data directory to store HuggingFace models')
 
    # Parse the arguments
    args = parser.parse_args()

    # Define the parameters
    params = {
        "author": args.author,
        "tags": args.tag,
        "search": args.search,
        "datadir": args.datadir,
    }

    models = make_request('https://huggingface.co/api/models', params=params)
    if models is None:
        return

    model_list = []
    # Iterate over the models
    for model in models:
        model_id = model['id']
        model_info = make_request(f'https://huggingface.co/api/models/{model_id}')
        if model_info is None:
            continue

        for sibling in model_info.get('siblings', []):
            rfilename = sibling.get('rfilename')
            if rfilename and args.filename in rfilename:
                model_list.append((model_id, rfilename))

    print(f"Found models: {len(model_list)}")
    # Choose the model
    model_list.sort(key=lambda x: x[0])
    if len(model_list) == 0:
        print("No models found")
        exit(1)
    elif len(model_list) == 1:
        model_choice = model_list[0]
    else:
        model_choice = get_user_choice(model_list)

    if model_choice is not None:
        model_id, rfilename = model_choice
        url = f"https://huggingface.co/{model_id}/resolve/main/{rfilename}"
        dest = f"{model_id.replace('/', '_')}_{rfilename}"

        print(f"Model ID: {model_id}, RFilename: {rfilename}, destination: {dest}")

        # Download the model to /data directory
        if not os.path.isdir(params['datadir']):
            # throw error if data directory does not exist
            print("Error - data directory does not exist")
            exit(-1)
        dest = os.path.join(params['datadir'], dest)

        # check if model is already downloaded
        if os.path.isfile(dest):
            print("Model already downloaded.")
            _, version = check_magic_and_version(dest)
            if version != args.version:
                print(f"Warning: Expected version {args.version}, but found different version in the file.")

            # Creating a symbolic link from destination to "model.bin"
            symlink_model(params['datadir'], dest)
            exit(0)
        print(f"Downloading {url} to {dest}...")
        download_file(url, dest, params)
        _, version = check_magic_and_version(dest)
        if version != args.version:
             print(f"Warning: Expected version {args.version}, but found different version in the file.")
    else:
        print("Error - model choice was None")
        exit(2)

if __name__ == '__main__':
    main()