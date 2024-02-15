# frozen_string_literal: true

RSpec.describe Rack::Cors::CsrfPrevention do
  let(:app) { ->(env) { [200, env, "hello"] } }
  let(:middleware) { Rack::Cors::CsrfPrevention.new(app) }
  let(:rack_response) { middleware.call(request) }
  let(:request_headers) { {} }
  let(:simple_request_header) { { "CONTENT_TYPE" => "application/x-www-form-urlencoded" } }
  let(:request) { env_for(path, request_headers) }

  before do |example|
    @status, @headers, @response = rack_response unless example.metadata[:skip_request]
  end

  context "to protected path" do
    let(:path) { "https://example.com/graphql" }

    context "with preflighted request" do
      let(:request_headers) { { "CONTENT_TYPE" => "application/json" } }

      it "pass" do
        expect(@status).to eq(200)
        expect(@response).to eq("hello")
      end

      it "logs", :skip_request do
        expect { rack_response }.to output(/Request is preflighted/).to_stdout
      end
    end

    context "with simple request" do
      context "from form" do
        let(:request_headers) { simple_request_header }

        it "rejected" do
          expect(@status).to eq(400)
          expect(@headers).to eq({ "Content-Type" => "text/plain" })
          expect(@response).to eq([<<~HEREDOC])
            This operation has been blocked as a potential Cross-Site Request Forgery (CSRF).

            Please either specify a "Content-Type" header (with a mime-type that is not one of application/x-www-form-urlencoded, multipart/form-data, text/plain) or provide one of the following headers: X-APOLLO-OPERATION-NAME, APOLLO-REQUIRE-PREFLIGHT.
          HEREDOC
        end

        it "logs", :skip_request do
          expect { rack_response }.to output(/Request isn't preflighted/).to_stdout
        end
      end

      context "without content-type header" do
        let(:request_headers) { {} }

        it "rejected" do
          expect(@status).to eq(400)
          expect(@headers).to eq({ "Content-Type" => "text/plain" })
          expect(@response).to eq([<<~HEREDOC])
            This operation has been blocked as a potential Cross-Site Request Forgery (CSRF).

            Please either specify a "Content-Type" header (with a mime-type that is not one of application/x-www-form-urlencoded, multipart/form-data, text/plain) or provide one of the following headers: X-APOLLO-OPERATION-NAME, APOLLO-REQUIRE-PREFLIGHT.
          HEREDOC
        end

        it "logs", :skip_request do
          expect { rack_response }.to output(/Request isn't preflighted/).to_stdout
        end
      end

      context "when required header provided" do
        let(:request_headers) do
          simple_request_header.merge!({
            "HTTP_X_APOLLO_OPERATION_NAME" => "test"
          })
        end

        it "pass" do
          expect(@status).to eq(200)
          expect(@response).to eq("hello")
        end

        it "logs", :skip_request do
          expect { rack_response }.to output(/Request is preflighted/).to_stdout
        end
      end
    end
  end

  context "to unprotected path" do
    let(:path) { "https://example.com/unprotected" }

    it "pass" do
      expect(@status).to eq(200)
      expect(@response).to eq("hello")
    end

    it "doesn't log", :skip_request do
      expect { rack_response }.to_not output.to_stdout
    end
  end

  context "when initialized with custom paths" do
    context "with string value" do
      let(:middleware) { Rack::Cors::CsrfPrevention.new(app, path: "/custom") }

      context "with simple request" do
        let(:request_headers) { simple_request_header }

        context "to protected path" do
          context "/custom" do
            let(:path) { "/custom" }

            it "rejected" do
              expect(@status).to eq(400)
            end
          end
        end

        context "to unprotected path" do
          let(:path) { "/unprotected" }

          it "pass" do
            expect(@status).to eq(200)
          end
        end
      end
    end

    context "with array value" do
      let(:middleware) { Rack::Cors::CsrfPrevention.new(app, paths: %w[/admin/gql /custom]) }

      context "with simple request" do
        let(:request_headers) { simple_request_header }

        context "to protected path" do
          context "/admin/gql" do
            let(:path) { "/admin/gql" }

            it "rejected" do
              expect(@status).to eq(400)
            end
          end

          context "/custom" do
            let(:path) { "/custom" }

            it "rejected" do
              expect(@status).to eq(400)
            end
          end
        end

        context "to unprotected path" do
          let(:path) { "/unprotected" }

          it "pass" do
            expect(@status).to eq(200)
          end
        end
      end
    end
  end

  context "when initialized with custom required headers" do
    let(:middleware) do
      Rack::Cors::CsrfPrevention.new(
        app,
        required_headers: %w[REQUIRED_HEADER SOME_SPECIAL_HEADER]
      )
    end
    let(:path) { "https://example.com/graphql" }

    context "with first required header" do
      let(:request_headers) { simple_request_header.merge!("HTTP_REQUIRED_HEADER" => "test") }

      it "pass" do
        expect(@status).to eq(200)
      end
    end

    context "with second required header" do
      let(:request_headers) { simple_request_header.merge!("HTTP_SOME_SPECIAL_HEADER" => "value") }

      it "pass" do
        expect(@status).to eq(200)
      end
    end

    context "with default apollo header" do
      let(:request_headers) { simple_request_header.merge!("HTTP_APOLLO_REQUIRE_PREFLIGHT" => "true") }

      it "pass" do
        expect(@status).to eq(200)
      end
    end

    context "with non-required header" do
      let(:request_headers) { simple_request_header.merge!("HTTP_OPTIONAL_HEADER" => "test") }

      it "rejected" do
        expect(@status).to eq(400)
      end
    end
  end

  private

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end
