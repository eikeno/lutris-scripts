#!/usr/bin/env python3
import json
import logging
import os
import signal
import sys
import tempfile

from datetime import datetime, timedelta
from gettext import gettext as _

import gi
gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")

from gi.repository import Gio, GLib, Gtk, GObject

LUTRIS_SRC_DIR = os.environ.get('LUTRIS_SRC_DIR')
if not LUTRIS_SRC_DIR:
    try:
        from lutris import settings
    except:
        print("Cannot import lutris. If not installed system wide, run from sources directory or set LUTRIS_SRC_DIR env var.")
        sys.exit(1)
else:
    try:
        sys.path.append(LUTRIS_SRC_DIR)
    except:
        print("Cannot change directory to %s", LUTRIS_SRC_DIR)
        sys.exit(1)
    from lutris import settings

from lutris.api import get_api_games, get_game_installers, read_api_key
from lutris.database.games import get_games
from lutris.database.services import ServiceGameCollection
from lutris.gui import dialogs
from lutris.gui.views.media_loader import download_media
from lutris.services.base import LutrisBanner, LutrisCoverart, LutrisCoverartMedium, LutrisIcon, OnlineService
from lutris.services.service_game import ServiceGame
from lutris.util import http
from lutris.util.log import logger

from lutris.services.lutris import download_lutris_media
from lutris.database import games as games_db

if __name__ == '__main__':
	for game in games_db.get_games():
		if os.path.exists(os.path.join(settings.COVERART_PATH, (game['slug'] + '.jpg'))):
			pass
		else:
			SLUG = game['slug'].replace("’", "")
			print("Trying media download for %s" % SLUG)
			sys.stderr.write(">> " + SLUG + '\n')
			download_lutris_media(SLUG)

	sys.exit(0)
