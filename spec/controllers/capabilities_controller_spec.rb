require 'rails_helper'
require 'spec_helper'

describe CapabilitiesController do
  let(:json) {JSON.parse(response.body)}

  describe '#create' do

    def createType params
      post 'create', params: params, format: :json
    end

    context 'with valid params for sensor' do
      before :each do
        createType({
          name: "teste0",
          description: "zero",
          capability_type: "sensor",
          })
      end
      it "returns a success response" do
        expect(response.status).to eq(201)
        expect(json["name"]).to eq("teste0")
        expect(json["description"]).to eq("zero")
        expect(json["capability_type"]).to eq("sensor")
      end
      it "is expected to respond with attributes" do
        expect(json["name"]).to eq("teste0")
        expect(json["description"]).to eq("zero")
        expect(json["capability_type"]).to eq("sensor")
        expect(json["id"]).to be_truthy
      end
      it "is expected to create a sensor capability in database" do
        expect(Capability.find_by_name "teste0").to be_truthy
      end
    end
    context 'with valid params for actuator' do
      before :each do
        createType({
          name: "teste1",
          description: "one",
          capability_type: "actuator",
          })
      end
      it "returns a success response" do
        expect(response.status).to eq(201)
      end
      it "is expected to respond with attributes" do
        expect(json["name"]).to eq("teste1")
        expect(json["description"]).to eq("one")
        expect(json["capability_type"]).to eq("actuator")
        expect(json["id"]).to be_truthy
      end
      it "is expected to create an actuator capability in database" do
        expect(Capability.find_by_name "teste1").to be_truthy
      end
    end

    context 'with valid params for information' do
      before :each do
        createType({
          name: "teste2",
          description: "two",
          capability_type: "information",
          })
      end

      it "returns a success response" do
        expect(response.status).to eq(201)
      end
      it "is expected to respond with attributes" do
        expect(json["name"]).to eq("teste2")
        expect(json["description"]).to eq("two")
        expect(json["capability_type"]).to eq("information")
        expect(json["id"]).to be_truthy
      end
      it "is expected to create an information capability in database" do
        expect(Capability.find_by_name "teste2").to be_truthy
      end
    end

    context 'with invalid params' do
      it "is expected to reject an invalid capability_type" do
        createType({
          name: "teste_fail",
          escription: "some description",
          capability_type: "invalid"
          })
        expect(response.status).to eq(400)
        expect(json["error"]).to eq("Bad capability_type")
        expect(Capability.find_by_name "teste_fail").to be_falsey
      end

      it "is expected to reject a creation with a duplicate name" do
          Capability.create_sensor(name: "teste_fail",
            description: "some description")

          post 'create',
                params: {
                  name: "teste_fail",
                  description: "some description",
                  capability_type: "sensor",
                  },
                format: :json

          expect(response.status).to eq(400)
          expect(json["error"]).to eq("Name has already been taken")
        end

        it "is expected to reject a creation without name" do
          createType({
            description: "some description",
            capability_type: "information"
            })

          expect(response.status).to eq(400)
          expect(json["error"]).to eq("Name can't be blank")
        end

        it "is expected to reject a creation without capability_type" do
          createType({
            name: "teste_fail",
            description: "some description"
            })
          expect(response.status).to eq(400)
          expect(json["error"]).to eq("Bad capability_type")
          expect(Capability.find_by_name "teste_fail").to be_falsey
        end
      end
    end

    describe '#index' do
      before :each do
        Capability.create_sensor(name: "Sensor1",
          description: "first sensor")
        Capability.create_sensor(name: "Sensor2",
          description: "second sensor")
        Capability.create_sensor(name: "Sensor3",
          description: "third sensor")
        Capability.create_actuator(name: "Actuator1",
          description: "first actuator")
        Capability.create_actuator(name: "Actuator2",
          description: "second actuator")
        Capability.create_actuator(name: "Actuator3",
          description: "third actuator")
        Capability.create_information(name: "Info1",
          description: "first information")
        Capability.create_information(name: "Info2",
          description: "second information")
        Capability.create_information(name: "Info3",
          description: "third information")
      end

      context 'Successful' do
        it "is expected to find all capabilities" do
          get 'index'
          expect(response.status).to eq(200)
          expect(json["capabilities"]).to be_truthy
          expect(json["capabilities"].count).to eq 9
        end

        it "is expected to find all sensors" do
          get 'index',
          params: {
            capability_type: "sensor"
          }
          expect(response.status).to eq(200)
          expect(json["capabilities"]).to be_truthy
          expect(json["capabilities"].count).to eq 3
        end

        it "is expected to find all actuators" do
          get 'index',
          params: {
            capability_type: "actuator"
          }
          expect(response.status).to eq(200)
          expect(json["capabilities"]).to be_truthy
          expect(json["capabilities"].count).to eq 3
        end

        it "is expected to find all information" do
          get 'index',
          params: {
            capability_type: "information"
          }
          expect(response.status).to eq(200)
          expect(json["capabilities"]).to be_truthy
          expect(json["capabilities"].count).to eq 3
        end
      end

      context 'Unsuccessful' do
        it "is expected to reject invalid capability types" do
          get 'index',
          params: {
            capability_type: "informatio"
          }
          expect(response.status).to eq(400)
          expect(json["error"]).to eq "could not find by capability type"
        end
      end
    end

    describe '#update' do
      before :each do
        Capability.create_sensor(name: "Sensor1",
          description: "first sensor")
      end

      context 'Successful' do
        it "is expected to update a capability description" do
          put 'update',
          params: {name: "Sensor1", description:"the best" }, format: :json
          expect(response.status).to eq(202)
          expect(json["name"]).to eq("Sensor1")
          expect(json["description"]).to eq("the best")
          expect(json["capability_type"]).to eq("sensor")
          expect(json["id"]).to be_truthy
          expect(Capability.find_by_name "Sensor1").to be_truthy
        end
      end

      context 'Unsuccessful' do
        it "is expected reject an invalid name" do
          put 'update',
          params: {name: "Sens", description:"the best" }, format: :json
          expect(response.status).to eq(400)
          expect(json["error"]).to eq("name not found")
        end
      end
    end

    describe '#destroy' do
      before :each do
        Capability.create_sensor(name: "Sensor1",
          description: "first sensor")
      end

      context 'Successful' do
        it "is expected to delete a capability" do
          delete 'destroy', params: {id: Capability.last.id }
          expect(response.status).to eq(200)
          expect(json["message"]).to eq("capability deleted")
          expect(Capability.find_by_name "Sensor1").to be_falsey
        end
      end

      context 'Unsuccessful' do
        it "is expected to return an error if an invalid id is passed" do
          delete 'destroy',
          params: {id: Capability.last.id+5000 }
          expect(response.status).to eq(400)
          expect(json["error"]).to eq("no capability found")
          expect(Capability.find_by_name "Sensor1").to be_truthy
        end
      end
    end
  end
