require "cloudconvert-ruby"

File.read(File.join(Dir.pwd, "first_page.pdf"), encoding: 'ASCII-8BIT')
#File.open(File.join(Dir.pwd, "first_page.pdf")),

@client = CloudConvert::Client.new(api_key:"NdGMEU0cnIPNvUQbdf9xQYT82cQT7SnWVcWSwRqedGdQLZ2EJPm8Q34glw6c5m5z")
@process = @client.build_process(input_format: :pdf, output_format: :jpg)
@process_response = @process.create
if @process_response[:success]
    @conversion_response = @process.convert(
        input: "upload",
        file: File.open(File.join(Dir.pwd, "first_page.pdf")),
        outputformat: :jpg,
        download: "true"
    )
end
if @conversion_response[:success]
     path = File.join(Dir.pwd, "cloudconvert.jpg")
     @download = @process.download(path)
end
