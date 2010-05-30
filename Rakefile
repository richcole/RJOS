#!/usr/bin/rake

class String
  def /(x)
    File.join(self, x)
  end
end

class Builder

  def initialize
    @build      = "build"
    @includes   = @build / "includes"
    @src_dir    = "src"
    @floppy_img = @build / "floppy.img"
    @rakefile   = "Rakefile"

    directory @build
    directory @includes

    file @floppy_img
    file @rakefile
    objects = []
    @bootloader = asm_to_bin("src/boot.asm")
    objects << asm("src/start.asm")
    objects << compile("src/kern.c")
    @kern = ld "src/linker.ld", "build/kern.bin", @bootloader, objects
    
    file @floppy_img => [@bootloader, @kern, @rakefile] do
      size = 0
      puts "Writing to #{@floppy_img}"
      File.open(@floppy_img, "w") do |img_file|
        data = File.read(@bootloader)
        img_file.write data
        size += data.size
        puts "Wrote #{data.size} data from #{@bootloader}"

        data = File.read(@kern)
        img_file.write data
        size += data.size
        puts "Wrote #{data.size} data from #{@kern}"

        pad_size = ((size / 512) * 512) - size
        if pad_size < 0 then
          pad_size += 512
          data = File.open("/dev/zero", "r") do |n| 
            img_file.write n.read(pad_size)
          end
          puts "Wrote #{pad_size} data to pad file"
        else
          puts "Not padding file because it's the right size"
        end
      end
    end

    task :disasm => [disasm(@kern), disasm(@floppy_img, "-s 0x200")]

    task :default => @floppy_img
    task :release => @floppy_img

    task :clean do
      sh "rm -rf build"
    end

#    file @floppy_image => [@rakefile, "src/boot.asm", @build_dir] do
#      sh "nasm -o #{@floppy_img} -f bin src/boot.asm"
#    end
  end

  def output(file, from, to)
    return @build / File.basename(file, from) + to
  end

  def asm_to_bin(file)
    obj_file = output(file, ".asm", ".bin")
    file obj_file => [file, @build, @rakefile] do
      sh "nasm -f bin -o #{obj_file} #{file}"
    end
    return obj_file
  end

  def asm(file)
    obj_file = output(file, ".asm", ".o")
    file obj_file => [file, @build, @rakefile] do
      sh "nasm -f elf64 -o #{obj_file} #{file}"
    end
    return obj_file
  end

  def proto_file(file)
    proto_file = @includes / File.basename(file, ".c") + "_proto.h"
    file proto_file => [file, @build, @build / "includes", @rakefile] do
      sh "cproto -sq #{file} > #{proto_file}"
    end
    return proto_file
  end 

  def compile(file)
    obj_file = output(file, ".c", ".o")
    opts = "-Wall -m64 -nostdinc -nostdlib -ffreestanding"
    file obj_file => [file, @build, @rakefile, proto_file(file)] do
      sh "gcc #{opts} -fPIC -c -I #{@includes} -o #{obj_file} #{file}"
    end
    return obj_file
  end

  def ld(ld_script, output, bootloader, objects)
    file output => [ld_script, @build, @rakefile, bootloader] + objects do
      sh "ld -T #{ld_script} -o #{output} #{objects.join(" ")}"
    end
    return output
  end

  def disasm(src, options="")
    output = src + ".dis"
    file output => [@build, src] do
      sh "ndisasm -b64 -i #{src} #{options}> #{output}"
    end
    return output
  end

end

Builder.new






