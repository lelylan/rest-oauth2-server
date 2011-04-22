require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "ResourceController" do

  context "with not existing access token" do
    before { @token = Factory(:oauth_access) }
    before { @token = Factory(:oauth_token) }
    before { @token_value = @token.token }
    before { @token_json  = {token: @token_value}.to_json }
    before { @token.destroy }

    scenario ".index" do
      visit "/pizzas?token=" + @token_value
      should_not_be_authorized
    end

    scenario ".show" do
      visit "/pizzas/0?token=" + @token_value
      should_not_be_authorized
    end

    scenario ".create" do
      page.driver.post("/pizzas", @token_json)
      should_not_be_authorized
    end

    scenario ".update" do
      page.driver.put("/pizzas/0", @token_json)
      should_not_be_authorized
    end

    scenario ".destroy" do
      page.driver.delete("/pizzas/0", @token_json)
      should_not_be_authorized
    end
  end

  context "with single action accesses" do
    before { @token_value = Factory(:oauth_token, scope: ["pizzas/index"]).token }
    before { @token_json  = {token: @token_value}.to_json }

    scenario ".index" do
      visit "/pizzas?token=" + @token_value
      page.should have_content "index"
    end

    scenario ".show" do
      visit "/pizzas/0?token=" + @token_value
      should_not_be_authorized
    end
  end


  context "with read accesses on a resource" do
    before { @token_value = Factory(:oauth_token_read).token }
    before { @token_json  = {token: @token_value}.to_json }

    scenario ".index" do
      visit "/pizzas?token=" + @token_value
      page.should have_content "index"
    end

    scenario ".show" do
      visit "/pizzas/0?token=" + @token_value
      page.should have_content "show"
    end

    scenario ".create" do
      page.driver.post("/pizzas", @token_json)
      should_not_be_authorized
    end

    scenario ".update" do
      page.driver.put("/pizzas/0", @token_json)
      should_not_be_authorized
    end

    scenario ".destroy" do
      page.driver.delete("/pizzas/0", @token_json)
      should_not_be_authorized
    end
  end


  context "with all accesses" do
    before { @token_value = Factory(:oauth_token).token }
    before { @token_json  = {token: @token_value}.to_json }

    scenario ".index" do
      visit "/pizzas?token=" + @token_value
      page.should have_content "index"
    end

    scenario ".show" do
      visit "/pizzas/0?token=" + @token_value
      page.should have_content "show"
    end

    scenario ".create" do
      page.driver.post("/pizzas", @token_json)
      page.should have_content "create"
    end

    scenario ".update" do
      page.driver.put("/pizzas/0", @token_json)
      page.should have_content "update"
    end

    scenario ".destroy" do
      page.driver.delete("/pizzas/0", @token_json)
      page.should have_content "destroy"
    end

    context "with token in the header" do
      before { @headers = Hash["Authorization", "OAuth2 #{@token_value}"] }
      before { page.driver.hacked_env.merge!(@headers) }

      scenario ".index" do
        visit "/pizzas"
        page.should have_content "index"
      end
    end
  end

end
