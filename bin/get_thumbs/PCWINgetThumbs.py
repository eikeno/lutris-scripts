#!/usr/bin/env python3

#import json
import base64 
import re
import os
import pdb
import pprint
import urllib.request
import urllib.parse
from urllib.parse import unquote
import sys
import requests
import sqlite3
import yaml

from bs4 import BeautifulSoup; # python3 -m pip intall bs4

_home = os.environ['HOME']
destpattern_image = "%s/.cache/lutris/coverart/" % _home
user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"
pga_file = "%s/.local/share/lutris/pga.db" % _home
pgadesc_file = "%s/.local/lutris/pga_gamesdesc.db" % _home
gamedir = "%s/.local/share/lutris/games/" % _home
pfid = 1

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


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
	cur.execute("SELECT slug, configpath FROM games WHERE platform='Windows' AND runner='wine';")
	rows = cur.fetchall()
	for row in rows:
		slug=str(row[0])
		sys.stderr.write('==========================')
		sys.stderr.write('row: ' + str(row[1]) + '\n')
		sys.stderr.write('slug: ' + slug + '\n')

		yfile = gamedir + row[1] + '.yml'
		sys.stderr.write('yaml file: ' + yfile + '\n')
		
		s = open(yfile, "r"); 
		y = yaml.safe_load(s); 
		
		# main_file = y['game']['working_dir']
		# sys.stderr.write('working_dir: ' + main_file + '\n')
		
		name = slug.replace("-", " ")
		sys.stderr.write('name: ' + name + '\n')

		# canon = re.sub(r'\(.*?\)', '', name)
		# canon = re.sub(r'\[.*?\]', '', canon)
		canon = name.replace(', The', '') # not likely but still nice to do
		canon = canon.strip()
		sys.stderr.write('canon: ' + canon + '\n')

		game=urllib.parse.quote_plus(canon)
		sys.stderr.write("game = " + game + '\n')

		tgdb_url = ('https://thegamesdb.net/search.php?name=%s&platform_id[]=%s' % (game, pfid))
		sys.stderr.write('tgdb_url : ' + tgdb_url + '\n')
		html_text = requests.get(tgdb_url).text
		soup = BeautifulSoup(html_text, 'html.parser')  # page de résultats, on va prendre le 1er
		res = soup.find(id='display')
		alink = soup.find('div', attrs={"class": 'col-6 col-md-2'})
		
		ahref=""
		if alink:
			soup2 = BeautifulSoup(str(alink), 'html.parser')  # section du lien vers la page de details
			ahref = soup2.find('a').get('href').replace("./", "https://thegamesdb.net/") # game details page exact url
			print("A HREF=" + ahref)
		
			soup3 = BeautifulSoup(requests.get(ahref).text, 'html.parser')  # loading result page
			release = soup3.find(string=re.compile('ReleaseDate: '))
			release_year = None
			if release:
				release_year = release.split('-')[0].replace('ReleaseDate: ', '')
			print(bcolors.OKGREEN + ('release_year: ' + str(release_year)) + bcolors.ENDC)

			genres = None
			_genres = soup3.find(string=re.compile('Genre\(s\):'))
			if _genres:
				genres = _genres.replace('Genre(s): ', '').lower()

			if genres:
				genres_l = genres.split(' | ')
				for g in genres_l:
					print(bcolors.OKGREEN + ('genre: ' + str(g)) + bcolors.ENDC)

			title = None
			title = soup3.find("h1").text
			desc = None
			if title:
				desc = soup3.find("p", attrs={'class': 'game-overview'}).text
				print(bcolors.OKCYAN + ('title: ' + str(title)) + bcolors.ENDC)
				print(bcolors.OKCYAN + ('desc: ' + str(desc)) + bcolors.ENDC)

			
			# Find game ID, needed to manage additional DB for descriptive contents
			cur.execute("SELECT id from games WHERE slug='%s';" % str(slug))
			
			rows = None
			rows = cur.fetchone()
			gameid=None
			if rows:
				gameid = str(rows[0])

			if desc and title and gameid:
				conndesc = create_connection(pgadesc_file)
				curdesc = conndesc.cursor()
				#import pdb; pdb.set_trace()
				print(">>>>>>>>>>>> INSERT OR IGNORE INTO gamesdesc (gameid, title, desc) VALUES (\"%s\", \"%s\", \"%s\")" %
					(
						str(gameid),
						str(title),
						urllib.parse.quote_plus(desc)
					)
				)
				#import pdb; pdb.set_trace()
				curdesc.execute("INSERT OR IGNORE INTO gamesdesc (gameid, title, desc) VALUES (\"%s\", \"%s\", \"%s\");" %
					(
						str(gameid),
						str(title),
						urllib.parse.quote_plus(desc)
					)
				)
				conndesc.commit()
				rowdesc = curdesc.fetchall()
				print(bcolors.OKGREEN + ('inserted desc in DB. %s' % str(rowdesc)) + bcolors.ENDC)

			if genres_l and gameid:
				# check if already exist:
				for g in genres_l:
					cur.execute("SELECT id FROM categories WHERE name = \"%s\";" % str(g))
					rows = cur.fetchall()

					if type(rows) == type([]): # is a list
						if len(rows) > 0:
							rows = rows[0]
						else:
							rows = 0
					if type(rows) == type(()): # is a tuple
						rows = rows[0]

					print("Found id: %s for category: '%s'." % (str(rows), str(g)))
					if rows == 0:
						## create new category
						print(bcolors.OKBLUE + ("INSERT OR IGNORE INTO categories (name) VALUES (\"%s\");" % str(g)) + bcolors.ENDC)
						cur.execute("INSERT OR IGNORE INTO categories (name) VALUES (\"%s\");" % str(g))
						conn.commit()
						# then get id:
						cur.execute("SELECT id FROM categories WHERE name = \"%s\";" % str(g))
						rows = cur.fetchall()[0][0]
						conn.commit()
					# now add the game to the category:
					cur.execute("INSERT OR IGNORE INTO games_categories (game_id, category_id) VALUES (\"%s\", \"%s\");" %
						(
							str(gameid),
							str(rows)
						)
					)

			if release_year:
				# print("%%%%%%%%%%%")
				# print("UPDATE OR IGNORE games SET year = '%s' WHERE slug='%s' ;" % (
						# str(release_year), str(slug)
					# )
				# )
				# print('%%%%%%%%%%')
				cur.execute("UPDATE OR IGNORE games SET year = '%s' WHERE slug='%s' ;" % (
						str(release_year), str(slug)
					)
				)
				conn.commit()
				rows = cur.fetchall()
				print(bcolors.OKBLUE + ('inserted year in DB: ' + str(rows)) + bcolors.ENDC)


		iurl = None

		try:
			iurl = res.find_all('img')[0].get('src')
		except:
			sys.stderr.write('no results in parsing, skip\n')
			pass

		sys.stderr.write("\niurl = " + str(iurl))

		if not iurl:
			print(bcolors.FAIL + ("\nNo image found") + bcolors.ENDC)
			sys.stderr.write('\n========\n')
			continue

		# FIX%E: check the found image ia a jpg, or name accordingly below :
		tgt_img = destpattern_image + slug + '.jpg'
		sys.stderr.write('\ntgt_img: %s\n' % tgt_img)
		if not os.path.exists(tgt_img):
			with open(tgt_img, "wb") as final_img:
				print(bcolors.OKGREEN + ("downloading final_img: %s" % str(final_img)) + bcolors.ENDC)
				#print("downloading final_img: " + str(final_img) + '\n')
				r=requests.get(iurl, headers={"User-Agent":user_agent})
				final_img.write(r.content)
				final_img.close()
		else:
			print(bcolors.WARNING + ("Image for %s already there, skipped." % str(game)) + bcolors.ENDC)

		sys.stderr.write('ok\n')
		sys.stderr.write('\n========\n')

if __name__ == '__main__':

	get_covers()	
	sys.exit(0)


 
