# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service do
  subject { create(:service) }

  it 'should allow updating field' do
    expect {
      subject.update(description: 'new')
    }.to change(subject, :description)
  end
end
