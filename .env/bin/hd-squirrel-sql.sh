#!/bin/bash

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2025 Hans Deragon - AGPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
# released under the GNU Affero General Public License which can be found at:
#
#     https://www.gnu.org/licenses/agpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

CLASSPATH=""
add2path CLASSPATH -f `find "${JAVA_HOME}/jre" -name "*.jar"`
CLASSPATH="${CLASSPATH}:${JAVALIBS}/db/mysql-connector-java-bin.jar"
CLASSPATH="${CLASSPATH}:${JAVALIBS}/db/sqlitejdbc.jar"
export CLASSPATH
"${HD_SOFTWARE_BASE_DIR}/nodist/noarch/squirrelsql/squirrel-sql.sh" &
