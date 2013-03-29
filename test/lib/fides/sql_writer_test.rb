require_relative '../../test_helper'

describe Fides::SqlWriter do

  before do
    class MyTestClass
      include Fides::SqlWriter
    end
  end

  describe "#strip_non_essential_spaces" do
    it 'removes newline characters' do
      dirty_string = "asdjfkals;dfj\n\n\nasdfjkl;asdf\n\n\nasjfklas;fdj"
      clean_string = "asdjfkals;dfj asdfjkl;asdf asjfklas;fdj"
      assert_equal clean_string, MyTestClass.strip_non_essential_spaces(dirty_string)
    end

    it 'turns multiple spaces into 1 space' do
      dirty_string = "a sdjfkals;dfj            asdfjkl;a     sdfasjfklas; fdj"
      clean_string = "a sdjfkals;dfj asdfjkl;a sdfasjfklas; fdj"
      assert_equal clean_string, MyTestClass.strip_non_essential_spaces(dirty_string)
    end

    it 'removes tabs' do
      dirty_string = "hel\t\tlowor\t\t\t\tld\t"
      clean_string = "hel lowor ld"
      assert_equal clean_string, MyTestClass.strip_non_essential_spaces(dirty_string)
    end

    it 'trips the string' do
      dirty_string = "               abc 123       "
      clean_string = "abc 123"
      assert_equal clean_string, MyTestClass.strip_non_essential_spaces(dirty_string)
    end
  end
end