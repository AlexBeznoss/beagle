module UserHelpers
  USERS = {
    default: {
      email: "user+clerk_test@beaglejobs.com",
      password: ">?AHEx@MzJ$J#(CE681W)"
    }
  }

  def users(name, field)
    USERS.dig(name, field)
  end

  def login_as(user_name)
    wait_for_clerk

    Capybara.default_max_wait_time.tap do |wait_time|
      Capybara.default_max_wait_time = 5
      script = <<-SCRIPT
        let [done] = arguments;

        async function login() {
          const res = await window.Clerk.client.signIn.create({
            identifier: "#{users(user_name, :email)}",
            password: "#{users(user_name, :password)}",
          });

          await window.Clerk.setActive({
            session: res.createdSessionId,
          });
        }

        login().then(() => done(true)).catch((e) => done(e));
      SCRIPT

      evaluate_async_script(script)
      Capybara.default_max_wait_time = wait_time
    end

    visit current_path
    assert_css '[data-profile-ready-value="true"]'
  end

  def current_user_id
    wait_for_clerk
    evaluate_script("window.Clerk.user.id")
  end

  def wait_for_clerk
    until evaluate_script("window.Clerk && window.Clerk.isReady()")
      sleep 0.5
    end
  end
end
