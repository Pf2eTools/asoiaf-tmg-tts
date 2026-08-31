using System.Security.Cryptography;
using Steamworks;

namespace SteamCloudUploader
{
    public class FileShare
    {
        public string path;
        public string hash;
        private string name;
        private string cloudName;
        private string cloudHash;
        private byte[] data;
        private bool isCompleted = false;


        public static FileShare Create(string path)
        {
            return new FileShare(path);
        }

        public FileShare(string path)
        {
            this.path = path;
            this.name = Path.GetFileName(path);
            this.data = File.ReadAllBytes(path);
            this.hash = Convert.ToHexString(SHA1.HashData(data));
            this.cloudName = $"{this.hash}_{this.name}";
            this.cloudHash = "";
        }

        public CloudData Share()
        {
            bool uploadSuccess = SteamRemoteStorage.FileWrite(cloudName, data, data.Length);
            if (!uploadSuccess) throw new Exception($"Failed uploading {cloudName}");

            CallResult<RemoteStorageFileShareResult_t> callResult = CallResult<RemoteStorageFileShareResult_t>.Create(OnShare);
            SteamAPICall_t apiCall = SteamRemoteStorage.FileShare(cloudName);
            callResult.Set(apiCall);

            while (!isCompleted)
            {
                SteamAPI.RunCallbacks();
                Thread.Sleep(250);
            }

            string url = $"https://steamusercontent-a.akamaihd.net/ugc/{cloudHash}/{hash}/";

            return new CloudData(name, url, data.Length);
        }

        private void OnShare(RemoteStorageFileShareResult_t pCallback, bool callFailed)
        {
            if (callFailed || pCallback.m_eResult != EResult.k_EResultOK) throw new Exception($"Error sharing {name}! | Result: {pCallback.m_eResult}");

            isCompleted = true;
            cloudHash = pCallback.m_hFile.ToString();
        }
    }

    public struct CloudData
    {
        public string Name;
        public string URL;
        public int Size;
        public string Date;

        public CloudData(string name, string url, int size)
        {
            Name = name;
            URL = url;
            Size = size;
            Date = DateTime.Now.ToString();
        }
    }
}