require './usage_parser'

RSpec.describe UsageParser do
  describe '#parse' do
    context 'Given a single string' do
      context 'Given an ID that does not end with 4 or 6' do
        let(:string) { '7291,293451' }

        let(:expected_object) do
          {
            id:         7291,
            bytes_used: 293451,

            mnc:    nil,
            dmcc:   nil,
            cellid: nil,
            ip:     nil,
          }
        end

        it 'Then it will return basic string data' do
          expect(UsageParser::parse(string)).to eq([expected_object])
        end
      end

      context 'Given an ID that ends with 4' do
        let(:string) { '7194,b33,394,495593,192' }

        let(:expected_object) do
          {
            id:         7194,
            mnc:        394,
            bytes_used: 495593,
            dmcc:       'b33',
            cellid:     192,

            ip:   nil,
          }
        end

        it 'Then it will return extended string data' do
          expect(UsageParser::parse(string)).to eq([expected_object])
        end
      end

      context 'Given an ID that ends with 6' do
        let(:string) { '316,0e893279227712cac0014aff' }

        let(:expected_object) do
          {
            id:         316,
            mnc:        3721,
            bytes_used: 12921,
            cellid:     578228938,
            ip:         '192.1.74.255',

            dmcc: nil,
          }
        end     

        it 'Then it will return hex string data' do
          expect(UsageParser::parse(string)).to eq([expected_object])
        end
      end
    end

    context 'Given an array of strings' do
      let(:array) do
        [
          '4,0d39f,0,495594,214', 
          '16,be833279000000c063e5e63d',
          '9991,2935',
        ]
      end

      let(:expected_array) do
        [
          {
            id:         4,
            mnc:        0,
            bytes_used: 495594,
            dmcc:       '0d39f',
            cellid:     214,
            ip:         nil,
          },
          {
            id:         16,
            mnc:        48771,
            bytes_used: 12921,
            cellid:     192,
            ip:         '99.229.230.61',
            dmcc:       nil,
          },
          {
            id:         9991,
            mnc:        nil,
            bytes_used: 2935,
            cellid:     nil,
            ip:         nil,
            dmcc:       nil,
          },
        ]
      end

      it 'Then it will parse each string according to its ID and return an array of data' do
        expect(UsageParser::parse(array)).to eq(expected_array)
      end
    end
  end
end
