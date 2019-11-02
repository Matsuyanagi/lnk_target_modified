#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
#	lnk ショートカットファイルの指す先のファイルの更新時刻を表示する
#	
#	
#	2019-11-02
#-----------------------------------------------------------------------------
require 'fileutils'
require 'date'
require 'time'
require 'win32/shortcut'

# Encoding.default_external="utf-8"
#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
settings = {
	
}

# 文字列の幅を求める。アスキー以外は幅2としてカウントしている
# http://ponde.hatenadiary.com/entry/2014/01/24/013232
class String
  def width
    self.length + self.chars.reject(&:ascii_only?).length
  end
end

FilenameAndLastupdated = Struct.new( :filename, :last_updated, :filename_width )

#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
def main( settings )
	files = []
	
	# 各ショートカットファイルの指す先のファイル情報を集める
	Dir.glob( "*.lnk".encode('utf-8'), File::FNM_CASEFOLD ) do |filename_lnk|
		short_cut = Win32::Shortcut.new( filename_lnk )

		filename_org = File.basename( short_cut.path ).encode('utf-8')
		if ( File.exist?( short_cut.path ) )
			last_updated_time = File::Stat.new( short_cut.path ).mtime
		else
			filename_org = "❌ " + filename_org
			last_updated_time = "----"
		end
		
		filename_and_lastupdated = FilenameAndLastupdated.new( filename_org, last_updated_time, filename_org.width )
		files << filename_and_lastupdated
	end

	# ファイル名でソート
	files.sort_by!{ |f| f.filename }

	# ファイル名の最大幅を求める
	max_width = 1
	files.each do |f|
		max_width = [ f.filename.width, max_width ].max
	end

	# 出力
	files.each do |f|
		space = " " * ( max_width - f.filename_width )
		printf( "%s%s : %s\n", f.filename, space, f.last_updated.to_s )
	end

end

main( settings )