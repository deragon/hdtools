#!/bin/bash
# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

CLASSPATH=""
add2path CLASSPATH -f `find "${JAVA_HOME}/jre" -name "*.jar"`
CLASSPATH="${CLASSPATH}:${JAVALIBS}/db/mysql-connector-java-bin.jar"
CLASSPATH="${CLASSPATH}:${JAVALIBS}/db/sqlitejdbc.jar"
export CLASSPATH
"${HD_SOFTWARE_BASE_DIR}/nodist/noarch/squirrelsql/squirrel-sql.sh" &
