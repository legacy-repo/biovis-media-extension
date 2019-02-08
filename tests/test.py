from mk_media_extension.extension import ChoppyPluginExtension

def test(text):
    import markdown
    plugin = ChoppyPluginExtension(configs={})
    print(markdown.markdown(text, extensions=[plugin]))


if __name__ == "__main__":
    text1 = '''
    # title

    # Just support string, boolean(True/False), integer, float
    @test(
        arg1=1,
        arg2="2",
        arg3=true,
    )
    '''

    text2 = '''
    # title

    # Just support string, boolean(True/False), integer, float
    @test(
        arg1=1,
        arg2="2",
        arg3=true,
    )
    '''
    text_lst = [text1, text2]
    for text in text_lst:
        test(text)