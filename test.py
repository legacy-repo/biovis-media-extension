from mk_media_extension.extension import ChoppyPluginExtension


def test(text):
    import markdown
    plugin = ChoppyPluginExtension(configs={})
    print(markdown.markdown(text, extensions=[plugin]))


if __name__ == "__main__":
    text = '''
    # JS file

    # @test-bokeh-plugin(number=2000)

    # @test-bokeh-plugin(number=1)

    # @igv-viewer()

    @test-shiny-plugin()
    '''

    text_lst = [text, ]
    for text in text_lst:
        test(text)
