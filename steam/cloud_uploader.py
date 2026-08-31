import os
import time
import bson
import json

os.environ["PYTHONNET_RUNTIME"] = "coreclr"
import clr
from System import Array, Byte

clr.AddReference("CloudUploader/lib/Steamworks.NET")
import Steamworks

clr.AddReference("CloudUploader/bin/Debug/net6.0/SteamCloudUploader")
from SteamCloudUploader import FileShare


class SteamcloudManager:
    def __init__(self):
        os.environ["SteamAppID"] = "286160"
        initialized = Steamworks.SteamAPI.Init()
        if not initialized:
            raise Exception("Failed to initialize Steamcloud Manager. Are you logged into Steam?")

        self.info = bson.loads(self.get_file("CloudInfo.bson"))
        self.folders = bson.loads(self.get_file("CloudFolder.bson"))

    @staticmethod
    def get_file(filename):
        size = Steamworks.SteamRemoteStorage.GetFileSize(filename)
        if size == 0:
            raise Exception(f"The file {filename} did not exist.")
        buffer = Array[Byte](size)
        Steamworks.SteamRemoteStorage.FileRead(filename, buffer, size)
        py_buffer = bytearray([buffer[ix] for ix in range(size)])
        # To convert the bytearray to a string, use .decode("ISO-8859-1")

        return py_buffer

    @staticmethod
    def upload_file(filename, data):
        did_upload = Steamworks.SteamRemoteStorage.FileWrite(filename, data, len(data))
        if not did_upload:
            raise Exception(f"Could not upload f{filename}!")

    def post_upload(self):
        py_bytes_folder = bson.dumps(self.folders)
        bytes_folder = Array[Byte](len(py_bytes_folder))
        for ix, b in enumerate(py_bytes_folder):
            bytes_folder[ix] = b
        self.upload_file("CloudFolder.bson", bytes_folder)

        py_bytes_info = bson.dumps(self.info)
        bytes_info = Array[Byte](len(py_bytes_info))
        for ix, b in enumerate(py_bytes_info):
            bytes_info[ix] = b
        self.upload_file("CloudInfo.bson", bytes_info)

        time.sleep(1)
        Steamworks.SteamAPI.Shutdown()

    def mkdir_exist_ok(self, path):
        split = path.split("\\")
        for ix in range(len(split)):
            subpath = "\\".join(split[:ix + 1])
            if subpath not in self.folders.values():
                self.folders[len(self.folders)] = subpath

    def share(self, path, folder):
        folder = folder.replace("/", "\\")
        file_share = FileShare(path)
        info_obj = file_share.Share()
        print(f'Shared "{path}" to "{info_obj.URL}"')
        info = {
            "Name": info_obj.Name,
            "URL": info_obj.URL,
            "Size": info_obj.Size,
            "Date": info_obj.Date,
            "Folder": folder,
        }
        self.info[file_share.hash] = info
        self.mkdir_exist_ok(folder)

        return info_obj.URL


def upload_assetbundles():
    with open("../assets/3d/scans/assetbundles.json") as f:
        asset_bundles = json.load(f)
    manager = SteamcloudManager()
    for key, val in asset_bundles.items():
        if val.get("url") is not None:
            continue
        path = f"../assets/3d/scans/{key}.unity3d"
        if not os.path.isfile(path):
            raise Exception(f"Asset at {path} does not exist!")
        url = manager.share(path, "dev/asoiaf/3d")
        asset_bundles[key]["url"] = url
    manager.post_upload()
    with open("../assets/3d/scans/assetbundles.json", "w") as f:
        json.dump(asset_bundles, f, indent=4)


def main():
    upload_assetbundles()


if __name__ == "__main__":
    main()
