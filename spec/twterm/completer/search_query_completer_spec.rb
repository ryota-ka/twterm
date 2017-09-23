require 'twterm/app'
require 'twterm/completer/search_query_completer'

RSpec.describe Twterm::Completer::SearchQueryCompleter do
  let(:app) { Twterm::App.new }
  let(:completer) { described_class.new(app) }

  describe '#complete' do
    subject { completer.complete(query) }

    context 'when the query is empty' do
      let(:query) { '' }

      it { is_expected.to contain_exactly(
           '@',
           'OR',
           ':)', ':(',
           '?',
           'filter:', '-filter:',
           'from:', '-from:',
           'lang:', '-lang:',
           'list:',
           'since:',
           'to:', '-to:',
           'until:',
           'url:', '-url:'
      ) }

    end

    context 'when the query is "-"' do
      let(:query) { '-' }

      it { is_expected.to contain_exactly '-filter:', '-from:', '-lang:', '-to:', '-url:' }
    end

    context 'when the query is "-f"' do
      let(:query) { '-f' }

      it { is_expected.to contain_exactly '-filter:', '-from:' }
    end

    context 'when the query is "-filter:"' do
      let(:query) { '-filter:' }

      it { is_expected.to contain_exactly '-filter:images ', '-filter:links ', '-filter:media ', '-filter:native_video ', '-filter:periscope ', '-filter:retweets ', '-filter:safe ', '-filter:twimg ', '-filter:vine ' }
    end

    context 'when the query is "-lang"' do
      let(:query) { '-lang' }

      it { is_expected.to contain_exactly '-lang:' }
    end

    context 'when the query is "-lang:"' do
      let(:query) { '-lang:' }

      it { is_expected.not_to include '-lang:' }
      it { is_expected.to include '-lang:de ' }
      it { is_expected.to include '-lang:en ' }
      it { is_expected.to include '-lang:fr ' }
      it { is_expected.to include '-lang:ja ' }
    end

    context 'when the query is ":"' do
      let(:query) { ':' }

      it { is_expected.to contain_exactly ':) ', ':( '  }
    end

    context 'when the query is "?"' do
      let(:query) { '?' }

      it { is_expected.to contain_exactly '? ' }
    end

    context 'when the query is "f"' do
      let(:query) { 'f' }

      it { is_expected.to contain_exactly 'filter:', 'from:' }
    end

    context 'when the query is "filter"' do
      let(:query) { 'filter' }

      it { is_expected.to contain_exactly 'filter:' }
    end

    context 'when the query is "filter:"' do
      let(:query) { 'filter:' }

      it { is_expected.to contain_exactly(
        'filter:images ',
        'filter:links ',
        'filter:media ',
        'filter:native_video ',
        'filter:periscope ',
        'filter:retweets ',
        'filter:safe ',
        'filter:twimg ',
        'filter:vine '
      ) }
    end

    context 'when the query is "l"' do
      let(:query) { 'l' }

      it { is_expected.to contain_exactly 'lang:', 'list:' }
    end

    context 'when the query is "lang:"' do
      let(:query) { 'lang:' }

      it { is_expected.not_to include 'lang:' }
      it { is_expected.to include 'lang:de ' }
      it { is_expected.to include 'lang:en ' }
      it { is_expected.to include 'lang:fr ' }
      it { is_expected.to include 'lang:ja ' }
    end

    context 'when the query is "u"' do
      let(:query) { 'u' }

      it { is_expected.to contain_exactly 'until:', 'url:' }
    end

    context 'with users' do
      let(:json) { JSON.parse(fixture('user.json'), symbolize_names: true) }

      before do
        json[:id] = 1
        json[:screen_name] = 'apple'
        app.user_repository.create(Twitter::User.new(json))

        json[:id] = 2
        json[:screen_name] = 'banana'
        app.user_repository.create(Twitter::User.new(json))
      end

      context 'when the query is "@"' do
        let(:query) { '@' }

        it { is_expected.to include '@apple ' }
        it { is_expected.to include '@banana ' }
      end

      context 'when the query is "@app"' do
        let(:query) { '@app' }

        it { is_expected.to include '@apple ' }
        it { is_expected.not_to include '@banana ' }
      end

      context 'when the query is "-from:"' do
        let(:query) { '-from:' }

        it { is_expected.to contain_exactly '-from:apple ', '-from:banana ' }
      end

      context 'when the query is "-from:app"' do
        let(:query) { '-from:app' }

        it { is_expected.to contain_exactly '-from:apple ' }
      end

      context 'when the query is "from:"' do
        let(:query) { 'from:' }

        it { is_expected.to contain_exactly 'from:apple ', 'from:banana ' }
      end

      context 'when the query is "from:app"' do
        let(:query) { 'from:app' }

        it { is_expected.to contain_exactly 'from:apple ' }
      end

      context 'when the query is "-to:"' do
        let(:query) { '-to:' }

        it { is_expected.to contain_exactly '-to:apple ', '-to:banana ' }
      end

      context 'when the query is "-to:app"' do
        let(:query) { '-to:app' }

        it { is_expected.to contain_exactly '-to:apple ' }
      end

      context 'when the query is "to:"' do
        let(:query) { 'to:' }

        it { is_expected.to contain_exactly 'to:apple ', 'to:banana ' }
      end

      context 'when the query is "to:app"' do
        let(:query) { 'to:app' }

        it { is_expected.to contain_exactly 'to:apple ' }
      end
    end

    context 'with lists' do
      let(:json) { JSON.parse(fixture('list.json'), symbolize_names: true) }

      before do
        json[:id] = 1
        json[:full_name] = '@central/tigers'
        app.list_repository.create(Twitter::List.new(json))

        json[:id] = 2
        json[:full_name] = '@pacific/buffaloes'
        app.list_repository.create(Twitter::List.new(json))

        p app.list_repository.all
      end

      context 'when the query is "list:"' do
        let(:query) { 'list:' }

        it { is_expected.to contain_exactly 'list:central/tigers ' , 'list:pacific/buffaloes ' }
      end

      context 'when the query is "list:cen"' do
        let(:query) { 'list:cen' }

        it { is_expected.to contain_exactly 'list:central/tigers ' }
      end
    end
  end
end
