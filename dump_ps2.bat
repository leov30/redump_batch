@echo off

if not exist "xidel.exe" echo THIS SCRIPT NEEDS xidel.exe&pause&exit

set "_site=http://redump.org/discs/system/ps2/"

(echo "Title","Media","Category","Region","Languages","Serials","EXE Date","Version","Edition","Number of Tracks","Size (Track 1)","CRC (Track 1)","MD5 (Track 1)","SHA-1 (Track 1)","URL")>output.tmp
for /l %%g in (1,1,23) do (
	title Page: %%g / 23
	for /f "delims=" %%h in ('xidel -s "%_site%?page=%%g" -e "//div[@id='main']/div[2]/table/tbody/tr/td/a/@href"') do call :get_info "http://redump.org%%h"

)

xidel -s output.tmp -e "replace( $raw, '\^', '')" >output.csv
del output.tmp
title FINISHED
pause&exit

:get_info
echo %~1

set "_title="
set "_tracks="
set "_serial="
set "_lang="
set "_media="
set "_region="
set "_category="
set "_version="
set "_edition="
set "_date="

for /l %%g in (0,1,3) do set "_track1[%%g]=" 

for /f "delims=" %%g in ('xidel -s "%~1" --output-format=cmd 
-e "_serial:=extract( $raw, '<th>Serial</th><td>(.+?)</td>', 1)" 
-e "_media:=extract( $raw, '<th>Media</th><td>(.+?)</td>', 1)" 
-e "_category:=extract( $raw, '<th>Category</th><td>(.+?)</td>', 1)" 
-e "_region:=//*[@id='main']/div[2]/table[1]/tbody/tr[4]/td/a/img/@title" 
-e "_version:=extract( $raw, '<th>Version</th><td>(.+?)</td>', 1)" 
-e "_edition:=extract( $raw, '<th>Edition</th><td>(.+?)</td>', 1)"
-e "_track1:=extract( $raw, '<td>1</td>.*?<td>\d+</td><td>(\d+)</td><td>([a-f0-9]{8})</td><td>([a-f0-9]{32})</td><td>([a-f0-9]{40})</td>', (1,2,3,4))"
-e "_tracks:=extract( $raw, '<th>Number of tracks</th><td>(\d)</td>', 1)"
-e "_title:=//*[@id='main']/h1"
-e "_lang:=[//*[@id='main']/div[2]/table[1]/tbody/tr[5]/td/img/@title]"
-e "_date:=extract( $raw, '<th>EXE date</th><td>(.+?)</td>', 1)"') do %%g

if "%_tracks%"=="" set "_tracks=1"
set "_lang=%_lang:"=%"
set "_lang=%_lang:[=%"
set "_lang=%_lang:]=%"

set "_title=%_title:"=""%"

(echo "%_title%","%_media%","%_category%","%_region%","%_lang%","%_serial%","%_date%","%_version%","%_edition%","%_tracks%","%_track1[0]%","%_track1[1]%","%_track1[2]%","%_track1[3]%","%~1")>>output.tmp

exit /b
