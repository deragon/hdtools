# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2022 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

# Written by Hans Deragon 2015-05-12 14:38:13 UTC
#

which hadoop >/dev/null 2>&1

if (( $? == 0 )); then

  # Hadoop exist on this system.  Generating aliases.
  # Now generating shorter alias to all hadoop commands.
  #
  # For instance, instead of 'hadoop fs -ls', type 'hls'
  # ──────────────────────────────────────────────────────────────────

  HADOOP_COMMANDS=`hadoop fs 2>&1 | perl -ne 'print if s/\s+\[-(\w+)\s.*/\1/g'`
  IFS_BCKP="${IFS}"
  IFS="
  "
  for HADOOP_COMMAND in ${HADOOP_COMMANDS}; do
    alias h${HADOOP_COMMAND}="hadoop fs -${HADOOP_COMMAND}"
  done

  IFS="${IFS_BCKP}"
  
  unset HADOOP_COMMANDS

  # ──────────────────────────────────────────────────────────────────
  # hconfig prints out the Hadoop configuration in a more readable, Java
  # properties form.
  alias hconfig='hadoop org.apache.hadoop.conf.Configuration | perl -ne "s%<property><name>%%g;s%</name><value>%=\"%g;s%</value><source>.*%\"%g; print if /.*?=\".*?\"/"'


  alias oconfig='oozie admin -oozie "${OOZIE_URL}" -configuration'
fi
