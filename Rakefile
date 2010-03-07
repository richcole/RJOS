

class String
  def /(x)
    File.join(self, x)
  end
end

class Builder

  def initialize
    @build_dir  = 'build'
    @src_dir    = 'src'
    @floppy_img = @build_dir / "floppy.img"

    directory @build_dir

    task :default => [ @floppy_image ]
    
    file "Rakefile"
    file "src/boot.asm"
    directory @build_dir
    file @floppy_image => ["Rakefile", "src/boot.asm", @build_dir] do
      sh "nasm -o #{@floppy_img} -f bin src/boot.asm"
    end
  end

end

Builder.new






