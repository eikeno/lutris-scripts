#!/usr/bin/env python3

#import json
import re
import os
import pdb
import pprint
import urllib.request
import urllib.parse
import sys
import requests
import sqlite3
import yaml

from bs4 import BeautifulSoup; # python3 -m pip intall bs4

_home = os.environ['HOME']
destpattern_image = "%s/.cache/lutris/coverart/" % _home
user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"
pga_file = "%s/.local/share/lutris/pga.db" % _home
gamedir = "%s/.local/share/lutris/games/" % _home
pfid = 4929 

def create_connection(db_file):
	""" 
	create a database connection to the SQLite database
	specified by the db_file
	:param db_file: database file
	:return: Connection object or None
	"""
	conn = None
	try:
		conn = sqlite3.connect(db_file)

	except (Error) as e:
		sys.stderr.write(e)
	
	return conn

def get_covers():
	"""
	Get covers suitable for 'coverart' use.
	basing on game name from yaml file's 'main_file:' value, instead of 
	usual slug, for easier name cleaning (thanks to paranthesis).
	"""
	conn = create_connection(pga_file)
	cur = conn.cursor()
	cur.execute("SELECT slug, configpath FROM games WHERE slug LIKE '%-msx2'; ")
	rows = cur.fetchall()
	for row in rows:
		slug=str(row[0])
		sys.stderr.write('row: ' + str(row[1]) + '\n')
		sys.stderr.write('slug: ' + slug + '\n')
		yfile = gamedir + row[1] + '.yml'
		sys.stderr.write('yaml file: ' + yfile + '\n')
		
		s = open(yfile, "r"); 
		y = yaml.safe_load(s); 
		
		main_file = y['game']['args']
		main_file=str(main_file).split("-cart2")[-1]
		sys.stderr.write('main_file: ' + main_file + '\n')
		
		name = os.path.basename(main_file).replace('.zip', '')
		sys.stderr.write('name: ' + name + '\n')
		
		canon = re.sub(r'\(.*?\)', '', name)
		canon = re.sub(r'\[.*?\]', '', canon)
		canon = canon.replace(', The', '')
		canon = canon.strip()
		canon = canon.replace('"', '')
		sys.stderr.write('canon: ' + canon + '\n')

		game=urllib.parse.quote_plus(canon)
		sys.stderr.write("game = " + game + '\n')

		tgdb_url = ('https://thegamesdb.net/search.php?name=%s&platform_id[]=%s' % (game, pfid))
		sys.stderr.write(tgdb_url)
		html_text = requests.get(tgdb_url).text
		soup = BeautifulSoup(html_text, 'html.parser')
		res = soup.find(id='display')

		iurl = None

		try:
			iurl = res.find_all('img')[0].get('src')
		except:
			sys.stderr.write('no results in parsing, skip\n')
			pass

		sys.stderr.write("\niurl = " + str(iurl))

		if not iurl:
			sys.stderr.write('\n========\n')
			continue

		tgt_img = destpattern_image + slug + '.jpg'
		sys.stderr.write('\ntgt_img: %s\n' % tgt_img)
		if not os.path.exists(tgt_img):
			with open(tgt_img, "wb") as final_img:
				print("downloading final_img: " + str(final_img) + '\n')
				r=requests.get(iurl, headers={"User-Agent":user_agent})
				final_img.write(r.content)
				final_img.close()
		else:
			sys.stderr.write ("\nImage for %s already there, skipped " % game)

		sys.stderr.write('ok\n')
		sys.stderr.write('\n========\n')

if __name__ == '__main__':

	get_covers()	
	sys.exit(0)


 
