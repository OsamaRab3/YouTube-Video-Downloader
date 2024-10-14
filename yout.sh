#!/bin/bash

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp could not be found. Please install it first."
    exit 1
fi

# Check if toilet is installed
if ! command -v toilet &> /dev/null; then
    echo "toilet could not be found. Please install it first."
    exit 1
fi

echo -e "\e[32;1m"

name="$(toilet -f term "YouTube Downloader")"
developer="$(toilet -f term "developed by @osama")"

for i in $(seq 1 $(echo "$name" | wc -l)); do
    printf "%s %s\n" "$(echo "$name" | sed -n "${i}p")" "$(echo "$developer" | sed -n "${i}p")"
done

echo -e "\e[0m"

if [ -z "$1" ]; then
    echo "Usage: $0 <URL>"
    echo "Please enter a link for the video or playlist."
    exit 1
fi

echo "Please select the download option:"
echo "1) Download single video"
echo "2) Download entire playlist"

read -p "Enter your choice (1-2): " download_choice

echo "Please select the desired quality:"
echo "1) 1080p"
echo "2) 720p"
echo "3) 480p"
echo "4) 360p"

read -p "Enter your choice (1-4): " quality_choice

case $quality_choice in
    1) quality="bestvideo[height<=1080]+bestaudio/best[height<=1080]" ;;
    2) quality="bestvideo[height<=720]+bestaudio/best[height<=720]" ;;
    3) quality="bestvideo[height<=480]+bestaudio/best[height<=480]" ;;
    4) quality="bestvideo[height<=360]+bestaudio/best[height<=360]" ;;
    *) echo "Invalid choice. Defaulting to best quality."; quality="best" ;;
esac


sanitize_filename() {
    echo "$1" | tr -d '\n' | sed 's/[^a-zA-Z0-9_-]/_/g' | cut -c1-50
}

# mkdir -p "downloaded"

if [ "$download_choice" -eq 1 ]; then
   
    file_name="$(yt-dlp --get-filename -o "downloaded/%(title).50s.%(ext)s" "$1")"
    sanitized_file_name=$(sanitize_filename "$file_name")

    if [ -f "downloaded/$sanitized_file_name" ]; then
        echo -e "\e[33mFile '$sanitized_file_name' already exists. Skipping download.\e[0m"
    else
        if yt-dlp -f "$quality" --merge-output-format mp4 -o "downloaded/$sanitized_file_name" "$1"; then
            echo -e "\e[32mDownload completed successfully!\e[0m"
        else
            echo -e "\e[31mError: Failed to download the video. Please check the URL and try again.\e[0m"
        fi
    fi
elif [ "$download_choice" -eq 2 ]; then
    playlist_url="$1"
    playlist_name="$(yt-dlp --get-title "$playlist_url")"
    sanitized_playlist_name=$(sanitize_filename "$playlist_name")
    mkdir -p "downloaded/$sanitized_playlist_name"

    if yt-dlp -f "$quality" --merge-output-format mp4 --yes-playlist -o "downloaded/$sanitized_playlist_name/%(title).50s.%(ext)s" "$playlist_url"; then
        echo -e "\e[32mPlaylist downloaded successfully!\e[0m"
    else
        echo -e "\e[31mError: Failed to download the playlist. Please check the URL and try again.\e[0m"
    fi
else
    echo -e "\e[31mInvalid download choice. Please run the script again.\e[0m"
fi
