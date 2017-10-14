require "spec_helper"

RSpec.describe Chimparse do
  context "Local implementation" do
    let(:content) { Chimparse::Filler.run(html_content, text_vars, html_vars) }

    context "text variables" do
      let(:html_content) { "<h2>*|THE_VAR|*</h2>" }
      let(:text_vars) { { THE_VAR: "Hello!" } }
      let(:html_vars) { {} }

      it "replaces the variable" do
        expect(content).to eq("<h2>Hello!</h2>")
      end
    end

    context "HTML variables" do
      let(:html_content) { "<h2>*|HTML:THE_VAR|*</h2>" }
      let(:text_vars) { {} }
      let(:html_vars) { { THE_VAR: "<a>A link</a>" } }

      it "replaces an HTML variable" do
        expect(content).to eq("<h2><a>A link</a></h2>")
      end
    end

    context "conditionals" do
      let(:text_vars) { { THIS_IS_TRUE: true } }
      let(:html_vars) { {} }

      context "IF TRUE -- ENDIF" do
        let(:html_content) {
          <<-EOF
          *|IF:THIS_IS_TRUE|*
          YES
          *|END:IF|*
          EOF
        }
        it "outputs the true branch" do
          expect(content).to include("YES")
        end
      end

      context "IF FALSE -- ENDIF" do
        let(:html_content) {
          <<-EOF
          *|IF:THIS_IS_FALSE|*
          NO
          *|END:IF|*
          EOF
        }
        it "outputs the true branch" do
          expect(content).not_to include("NO")
        end
      end

      context "multiple" do
        after do
          expect(content).to include("YES")
          expect(content).not_to include("NO")
        end

        context "IF TRUE -- ELSE -- ENDIF" do
          let(:html_content) {
            <<-EOF
            *|IF:THIS_IS_TRUE|*
            YES
            *|ELSE:|*
            NO
            *|END:IF|*
            EOF
          }
          it "outputs the true branch" do
          end
        end

        context "IF FALSE -- ELSE -- ENDIF" do
          let(:html_content) {
            <<-EOF
            *|IF:THIS_IS_FALSE|*
            NO
            *|ELSE:|*
            YES
            *|END:IF|*
            EOF
          }
          it "outputs the true branch" do
          end
        end

        context "IF TRUE -- ELSEIF TRUE -- ELSE -- ENDIF" do
          let(:html_content) {
            <<-EOF
            *|IF:THIS_IS_TRUE|*
            YES
            *|ELSEIF:THIS_IS_ALSO_TRUE|*
            NO
            *|ELSE:|*
            NO
            *|END:IF|*
            EOF
          }
          it "outputs the true branch" do
          end
        end

        context "IF TRUE -- ELSEIF FALSE -- ELSE -- ENDIF" do
          let(:html_content) {
            <<-EOF
            *|IF:THIS_IS_TRUE|*
            YES
            *|ELSEIF:THIS_IS_FALSE|*
            NO
            *|ELSE:|*
            NO
            *|END:IF|*
            EOF
          }
          it "outputs the true branch" do
          end
        end

        context "IF FALSE -- ELSEIF TRUE -- ELSE -- ENDIF" do
          let(:html_content) {
            <<-EOF
            *|IF:THIS_IS_FALSE|*
            NO
            *|ELSEIF:THIS_IS_TRUE|*
            YES
            *|ELSEIF:THIS_IS_ALSO_TRUE_BUT_DOESNT_MATTER|*
            NO
            *|ELSE:|*
            NO
            *|END:IF|*
            EOF
          }
          it "outputs the true branch" do
          end
        end

        context "IF FALSE -- ELSEIF FALSE -- ELSE -- ENDIF" do
          let(:html_content) {
            <<-EOF
            *|IF:THIS_IS_FALSE|*
            NO
            *|ELSEIF:THIS_IS_FALSE|*
            NO
            *|ELSE:|*
            YES
            *|END:IF|*
            EOF
          }
          it "outputs the true branch" do
          end
        end
      end
    end
  end
end
