#!/usr/bin/env python3

import json
import re
import pdb
import pprint
import urllib.request
import urllib.parse
import sys
import requests
from bs4 import BeautifulSoup; # python3 -m pip intall bs4

destpattern="/storage/GAMES_MASTER/RETROARCH/thumbnails/SNK - Neo Geo CD/Named_Boxarts/%s.jpg"
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"

def get_thumb_or_die_trying(json_pl_file, pfid):
	"""
	json_pl_file:	full path to json retroarch playlist file (str)
	pfid: 		platform id as per thegamesdb.net (int)
	"""
	with open(json_pl_file) as f:
		j = json.load(f)
		items = j['items']
		for i in items:
			print('=========')
			label=i['label']

			slabel=label.replace("(Rev 1)", "")
			slabel=slabel.replace("(Rev 2)", "")
			slabel=slabel.replace("(Rev A)", "")
			slabel=slabel.replace("(Rev B)", "")
			slabel=re.sub(r'\([^)]*\)', '', slabel).rstrip()
			slabel=re.sub(r'\[[^)]*\]', '', slabel)

			slabel=slabel.replace(": ", " ")
			slabel=slabel.replace("!", "")
			slabel=slabel.replace("&", "")
			slabel=slabel.replace("#", "")
			slabel=slabel.replace("'", "")
			slabel=slabel.replace("Bros.", "bros")
			slabel=slabel.replace("Jr.", "jr")
			slabel=slabel.replace("U.S.", "us")
			slabel=slabel.replace("Dr.", "dr")
			slabel=slabel.replace("Ms.", "ms")
			slabel=slabel.replace("Vol. ", "vol ")
			slabel=slabel.replace(", The", " ")
			slabel=slabel.replace(", the", " ")
			slabel=slabel.replace(", ", " ")
			slabel=slabel.replace(",", "")
			slabel=slabel.replace("+", "")
			slabel=slabel.replace(".", "")
			slabel=slabel.replace(" - ", " ")
			slabel=slabel.replace("  ", " ")
			slabel=slabel.replace("  ", " ")
			slabel=slabel.replace("(", "")
			slabel=slabel.replace(")", "")
			slabel=re.sub(r' $', '', slabel)

			slabel=urllib.parse.quote_plus(slabel)

			print('slabel: ', slabel)


			tgdb_url = ('https://thegamesdb.net/search.php?name=%s&platform_id[]=%s' % (slabel, pfid))
			html_text = requests.get(tgdb_url).text
			soup = BeautifulSoup(html_text, 'html.parser')
			res = soup.find(id='display')

			iurl = None

			try:
				iurl = res.find_all('img')[0].get('src')
			except:
				print('no results in parsing, skip')
				pass

			print("iurl = ", iurl)

			if not iurl:
				continue
			#print("destpattern: ", (destpattern % label))
			with open(destpattern % label, "wb") as final_img:
				print("final_img: ", final_img)
				r=requests.get(iurl, headers={"User-Agent":user_agent})
				final_img.write(r.content)
				final_img.close()

			print("ok")
		
if __name__ == '__main__':
	get_thumb_or_die_trying(
		"/storage/GAMES_MASTER/RETROARCH/playlists/SNK - Neo Geo CD.lpl",
		4956
	)
	sys.exit(0)


 
