# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this code.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

# Written by Hans Deragon 2015-05-12 14:38:13 UTC

# Download Hadoop Core from:  http://www.apache.org/dyn/closer.cgi/hadoop/core
# Should be a file like:  hadoop-3.1.1.tar.gz
# Install it somewhere.
#
# In "${HD_CORP_DIR}/env.noarch.pre.sh", add to the path the bin directory.
# For Cygwin, add:
#
#   add2path PATH "/cygdrive/c/programs-hd/hadoop-3.1.1/bin"

if which hadoop >/dev/null 2>&1; then

  # Hadoop exist on this system.  Generating aliases.
  # Now generating shorter alias to all hadoop commands.
  #
  # For instance, instead of 'hadoop fs -ls', type 'hls'
  # ──────────────────────────────────────────────────────────────────

  # En 2019, configurer HADOOP_HOME de cette manière cause des problèmes.
  # Ce code reste en commentaire et devrait disparaître après 2020-01-01.
  #hd_SetVariableIfNotAlreadySet HADOOP_HOME $(which hadoop | sed -r 's%/bin/.*%%g')
  # À la place, on créer cdhadoop en fonction de la plateforme détectée.
  runCommandIfDirsExist 'alias cdhadoop="cdprint \"${DIRECTORY}\""' /usr/hdp/current /usr/hdp/current

  # 'hadoop fs' is more generic and can apply to many filesystems, not simply
  # HDFS.  Thus, it is preferrable compared to 'hdfs dfs'.
  # See:  https://stackoverflow.com/questions/18142960/whats-the-difference-between-hadoop-fs-shell-commands-and-hdfs-dfs-shell-co
  HADOOP_COMMANDS=`hadoop fs 2>&1 | perl -ne 'print if s/\s+\[-(\w+)\s.*/\1/g'`
  IFS_BCKP="${IFS}"
  IFS="
"
  for HADOOP_COMMAND in ${HADOOP_COMMANDS}; do
    alias h${HADOOP_COMMAND}="hadoop fs -${HADOOP_COMMAND}"
  done
  unset HADOOP_COMMAND HADOOP_COMMANDS
  IFS="${IFS_BCKP}"

  # ──────────────────────────────────────────────────────────────────
  # hconfig prints out the Hadoop configuration in a more readable, Java
  # properties form.
  alias hconfig='hadoop org.apache.hadoop.conf.Configuration | perl -ne "s%<property><name>%%g;s%</name><value>%=\"%g;s%</value><source>.*%\"%g; print if /.*?=\".*?\"/"'

  #alias oconfig='oozie admin -oozie "${OOZIE_URL}" -configuration'

  # Alias 'l' shows the status of a job every 10 seconds.
  # Example:  l 0000004-190531164302960-oozie-oozi-W
  alias l='hdwhileloop -p 10 oozie job -info'
fi
