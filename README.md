json2java
=========

Ruby script to generate java (schema/model) class (to use with gson.fromJson) from json.


Motivation
==========

For android applications, I use Gson `gson.fromJson(response, JavaClass)` to parse and display json responses from web server. However, it is a dull task to manually create model classes for every json reponse. So, this script is written to generate those model classes automagically.


Example Usage
=============

```json
trhura @ json2java $ curl -s "http://192.168.10.102:8000/api/v1/participant/7438411/?username=trhura&api_key=fb3b645833893b64b23a9059a4523ac640eabdb0&accreditation_number=4504524644" | python -mjson.tool
{
    "access_areas": "IBC",
    "access_venues": "2,4,6",
    "accomodations": [
        {
            "accomodation": {
                "city": "YGN",
                "id": 4,
                "place": "Excel Treasure Hotel",
                "room": "00004"
            },
            "enddate": "2013-12-30",
            "id": 1,
            "startdate": "2013-12-29"
        },
        {
            "accomodation": {
                "city": "PTN",
                "id": 42,
                "place": "Aureum Palace Hotel",
                "room": "00042"
            },
            "enddate": "2013-12-07",
            "id": 2,
            "startdate": "2013-12-31"
        }
    ],
    "accreditation_number": "4504524644",
    "accreditation_type": 3,
    "card_number": "7438411",
    "country_code": "MAS",
    "dinning": true,
    "email": "abdul.aziz.khalil@frontiir.net",
    "family_name": "",
    "first_name": "",
    "function": "Deputy-Director",
    "gender": "F",
    "name": "Abdul Aziz Khalil",
    "nationality": "Malaysia",
    "phone": "09-731-694-68",
    "responsible_organization": "International Golf Federation",
    "seat_authority": "AS",
    "sport": "Water polo",
    "sports_village": "I,R",
    "transportation": "T2",
    "type": 4
}
```

```java
trhura @ json2java$ curl -s "http://192.168.10.102:8000/api/v1/participant/7438411/?username=trhura&api_key=fb3b645833893b64b23a9059a4523ac640eabdb0&accreditation_number=4504524644" | ./json2java.rb
public class ChangeThisClassName {
    @SerializedName("access_areas") private String accessAreas;
    @SerializedName("access_venues") private String accessVenues;
    @SerializedName("accomodations") private List<Accomodations> accomodations;
    @SerializedName("accreditation_number") private String accreditationNumber;
    @SerializedName("accreditation_type") private int accreditationType;
    @SerializedName("card_number") private String cardNumber;
    @SerializedName("country_code") private String countryCode;
    @SerializedName("dinning") private Boolean dinning;
    @SerializedName("email") private String email;
    @SerializedName("family_name") private String familyName;
    @SerializedName("first_name") private String firstName;
    @SerializedName("function") private String function;
    @SerializedName("gender") private String gender;
    @SerializedName("name") private String name;
    @SerializedName("nationality") private String nationality;
    @SerializedName("phone") private String phone;
    @SerializedName("responsible_organization") private String responsibleOrganization;
    @SerializedName("seat_authority") private String seatAuthority;
    @SerializedName("sport") private String sport;
    @SerializedName("sports_village") private String sportsVillage;
    @SerializedName("transportation") private String transportation;
    @SerializedName("type") private int type;

    public String getAccessAreas {
        return this.accessAreas;
    }

    public String getAccessVenues {
        return this.accessVenues;
    }

    public List<Accomodations> getAccomodations {
        return this.accomodations;
    }

    public String getAccreditationNumber {
        return this.accreditationNumber;
    }

    public int getAccreditationType {
        return this.accreditationType;
    }

    public String getCardNumber {
        return this.cardNumber;
    }

    public String getCountryCode {
        return this.countryCode;
    }

    public Boolean getDinning {
        return this.dinning;
    }

    public String getEmail {
        return this.email;
    }

    public String getFamilyName {
        return this.familyName;
    }

    public String getFirstName {
        return this.firstName;
    }

    public String getFunction {
        return this.function;
    }

    public String getGender {
        return this.gender;
    }

    public String getName {
        return this.name;
    }

    public String getNationality {
        return this.nationality;
    }

    public String getPhone {
        return this.phone;
    }

    public String getResponsibleOrganization {
        return this.responsibleOrganization;
    }

    public String getSeatAuthority {
        return this.seatAuthority;
    }

    public String getSport {
        return this.sport;
    }

    public String getSportsVillage {
        return this.sportsVillage;
    }

    public String getTransportation {
        return this.transportation;
    }

    public int getType {
        return this.type;
    }

    public class Accomodations {
        @SerializedName("accomodation") private Accomodation accomodation;
        @SerializedName("enddate") private String enddate;
        @SerializedName("id") private int id;
        @SerializedName("startdate") private String startdate;

        public Accomodation getAccomodation {
            return this.accomodation;
        }

        public String getEnddate {
            return this.enddate;
        }

        public int getId {
            return this.id;
        }

        public String getStartdate {
            return this.startdate;
        }

        public class Accomodation {
            @SerializedName("city") private String city;
            @SerializedName("id") private int id;
            @SerializedName("place") private String place;
            @SerializedName("room") private String room;

            public String getCity {
                return this.city;
            }

            public int getId {
                return this.id;
            }

            public String getPlace {
                return this.place;
            }

            public String getRoom {
                return this.room;
            }

        }

    }

}
```

TODO/Bugs
==========

* Handle `json` null value
* for array values, change plural (key) name to singular (class) name