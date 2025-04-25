#!/usr/bin/env python3
# $0 GAME_SLUG

import json
import pdb
import pprint
import urllib.request
import urllib.parse
import sys, os
import requests
import re
from bs4 import BeautifulSoup; # python3 -m pip intall bs4

pfid=10 # sony playstation

myhome=os.getenv("HOME")

destpattern="%s/.cache/lutris/coverart/%s.jpg"
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"

def get_thumb_or_die_trying(gamename):

	print('=========')
	game=gamename.replace("-psx", "")
	game=game.replace("-u-", "-")
	game=game.replace("-f-", "-")
	clean=re.sub(r"-slus-[0-9]{5}", "", game)
	clean=re.sub(r"-scus-[0-9]{5}", "", clean)
	clean=re.sub(r"-sles-[0-9]{5}", "", clean)
	clean=re.sub(r"-sces-[0-9]{5}", "", clean)
	clean=re.sub(r"-disc[0-9]{1,2}of[0-9]{1,2}", "", clean)
	clean=clean.replace("-ntsc", "")
	clean=clean.replace("-s-", "'s ")
	clean=clean.replace("-", " ")
	clean=clean.replace("  ", " ")
	
	
	slabel=urllib.parse.quote_plus(clean)

	print('game: ', clean)

	tgdb_url = ('https://thegamesdb.net/search.php?name=%s&platform_id[]=%s' % (slabel, pfid))
	html_text = requests.get(tgdb_url).text
	soup = BeautifulSoup(html_text, 'html.parser')
	res = soup.find(id='display')
	print("res: " + str(len(res)))
	iurl=''

	try:
		iurl = res.find_all('img')[0].get('src')
	except:
		print('error in parsing, skip')
		pass


	print("iurl = ", iurl)
	print('\n')

	if iurl:
		print("IURL: " + iurl)
		with open(destpattern % (myhome, gamename), "wb") as final_img:
			r=requests.get(iurl, headers={"User-Agent":user_agent})
			final_img.write(r.content)
			print("Write OK")
	
	print("ok")
		
if __name__ == '__main__':
	get_thumb_or_die_trying(sys.argv[1])
	sys.exit(0)


 
