require 'rails_helper'

describe Api::UsersController, type: :controller do
  before :each do
    @user1 = create(:user, email: 'usertest@email.com', password: 'userpass')
  end

  describe 'POST login' do
    before :each do
      create(:user, email: 'user@email.com', password: 'userpass')
    end

    it 'should return the token if valid username/password' do
      post :login, params: { email: 'user@email.com', password: 'userpass' }

      expect(response).to have_http_status(:ok)
      response_hash = JSON.parse(response.body)
      user_data = response_hash['user']

      expect(user_data['token']).to be_present
    end

    it 'should return an error if invalid username/password' do
      post :login, params: { email: 'invalid', password: 'user' }

      expect(response).to have_http_status(401)
    end
  end

  describe 'GET show' do
    it 'should return unauthorized if not logged in' do
      get :show, params: {
        id: @user1.id
      }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'should return ok if golfer logged in' do
      sign_in(@user1)
      get :show, params: {
        id: @user1.id
      }

      expect(response).to have_http_status(:ok)
      response_hash = JSON.parse(response.body)
      user = response_hash['user']
      scores = response_hash['scores']

      expect(user['id']).to eq @user1.id
      expect(user['email']).to eq @user1.email
      expect(scores.size).to eq @user1.scores.size
    end
  end
end
