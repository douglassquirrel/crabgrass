# CountrySelect
module ActionView
  module Helpers
    module FormOptionsHelper
      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
      def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
        ## CRABGRASS HACK
        # use InstanceTag.new Rails 2.1 calling convention, not 2.3
        InstanceTag.new(object, method, self, nil, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
      end
      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
      # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
      # that they will be listed above the rest of the (long) list.
      #
      # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
      def country_options_for_select(selected = nil, priority_countries = nil)
        country_options = ""

        if priority_countries
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end

        return country_options + options_for_select(COUNTRIES, selected)
      end
      # All the countries included in the country_options output.
      COUNTRIES = ["Afghanistan",
       "Albania",
       "Algeria",
       "American Samoa",
       "Andorra",
       "Angola",
       "Anguilla",
       "Antigua and Barbuda",
       "Argentina",
       "Armenia",
       "Aruba",
       "Australia",
       "Austria",
       "Azerbaijan",
       "Azores Islands",
       "Bahamas",
       "Bahrain",
       "Bangladesh",
       "Barbados",
       "Belarus",
       "Belgium",
       "Belize",
       "Benin",
       "Bermuda",
       "Bhutan",
       "Bolivia",
       "Bosnia and Herzegovina",
       "Botswana",
       "Brazil",
       "British Virgin Islands",
       "Brunei Darussalam",
       "Bulgaria",
       "Burkina Faso",
       "Burundi",
       "Cambodia",
       "Cameroon",
       "Canada",
       "Cape Verde",
       "Cayman Islands",
       "Central African Republic",
       "Chad",
       "Chile",
       "China",
       "Christmas Island",
       "Colombia",
       "Comoros",
       "Congo",
       "Cook Islands",
       "Costa Rica",
       "C\303\264te d'Ivoire",
       "Croatia",
       "Cuba",
       "Cyprus",
       "Czech Republic",
       "Democratic People's Republic of Korea",
       "Democratic Republic of the Congo",
       "Denmark",
       "Djibouti",
       "Dominica",
       "Dominican Republic",
       "Ecuador",
       "Egypt",
       "El Salvador",
       "Equatorial Guinea",
       "Eritrea",
       "Estonia",
       "Ethiopia",
       "Falkland Islands (Malvinas)",
       "Faroe Islands",
       "Fiji",
       "Finland",
       "France",
       "French Guiana",
       "French Polynesia",
       "Gabon",
       "Gambia",
       "Gaza Strip",
       "Georgia",
       "Germany",
       "Ghana",
       "Gibraltar",
       "Greece",
       "Greenland",
       "Grenada",
       "Guadeloupe",
       "Guam",
       "Guatemala",
       "Guernsey",
       "Guinea",
       "Guinea-Bissau",
       "Guyana",
       "Haiti",
       "Honduras",
       "Hungary",
       "Iceland",
       "India",
       "Indonesia",
       "Iran (Islamic Republic of)",
       "Iraq",
       "Ireland",
       "Isle of Man",
       "Israel",
       "Italy",
       "Jamaica",
       "Japan",
       "Jersey",
       "Jordan",
       "Kazakhstan",
       "Kenya",
       "Kiribati",
       "Kuwait",
       "Kyrgyzstan",
       "Lao People's Democratic Republic",
       "Latvia",
       "Lebanon",
       "Lesotho",
       "Liberia",
       "Libyan Arab Jamahiriya",
       "Liechtenstein",
       "Lithuania",
       "Luxembourg",
       "Macao",
       "Madagascar",
       "Madeira",
       "Malawi",
       "Malaysia",
       "Maldives",
       "Mali",
       "Malta",
       "Marshall Islands",
       "Martinique",
       "Mauritania",
       "Mauritius",
       "Mayotte",
       "Mexico",
       "Micronesia, Federated States of",
       "Moldova, Republic of",
       "Monaco",
       "Mongolia",
       "Montenegro",
       "Montserrat",
       "Morocco",
       "Mozambique",
       "Myanmar",
       "Namibia",
       "Nauru",
       "Nepal",
       "Netherlands",
       "Netherlands Antilles",
       "New Caledonia",
       "New Zealand",
       "Nicaragua",
       "Niger",
       "Nigeria",
       "Niue",
       "Norfolk Island",
       "Northern Mariana Islands",
       "Norway",
       "Occupied Palestinian Territory",
       "Oman",
       "Pakistan",
       "Palau",
       "Panama",
       "Papua New Guinea",
       "Paraguay",
       "Peru",
       "Philippines",
       "Pitcairn Island",
       "Poland",
       "Portugal",
       "Puerto Rico",
       "Qatar",
       "Republic of Korea",
       "R\303\251union",
       "Romania",
       "Russian Federation",
       "Rwanda",
       "Saint Helena",
       "Saint Kitts and Nevis",
       "Saint Lucia",
       "Saint Pierre and Miquelon",
       "Saint Vincent and the Grenadines",
       "Samoa",
       "San Marino",
       "Sao Tome and Principe",
       "Saudi Arabia",
       "Senegal",
       "Serbia",
       "Seychelles",
       "Sierra Leone",
       "Singapore",
       "Slovakia",
       "Slovenia",
       "Solomon Islands",
       "Somalia",
       "South Africa",
       "Spain",
       "Sri Lanka",
       "Sudan",
       "Suriname",
       "Svalbard",
       "Swaziland",
       "Sweden",
       "Switzerland",
       "Syrian Arab Republic",
       "Taiwan",
       "Tajikistan",
       "Thailand",
       "The former Yugoslav Republic of Macedonia",
       "Timor-Leste",
       "Togo",
       "Tokelau",
       "Tonga",
       "Trinidad and Tobago",
       "Tunisia",
       "Turkey",
       "Turkmenistan",
       "Turks and Caicos Islands",
       "Tuvalu",
       "Uganda",
       "Ukraine",
       "United Arab Emirates",
       "United Kingdom of Great Britain and Northern Ireland",
       "United Republic of Tanzania",
       "United States of America",
       "United States Virgin Islands",
       "Uruguay",
       "Uzbekistan",
       "Vanuatu",
       "Venezuela (Bolivarian Republic of)",
       "Viet Nam",
       "Wallis and Futuna",
       "West Bank",
       "Western Sahara",
       "Yemen",
       "Zambia",
       "Zimbabwe"] unless const_defined?("COUNTRIES")
    end

    class InstanceTag
      def to_country_select_tag(priority_countries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select",
          add_options(
            country_options_for_select(value, priority_countries),
            options, value
          ), html_options
        )
      end
    end

    class FormBuilder
      def country_select(method, priority_countries = nil, options = {}, html_options = {})
        @template.country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
      end
    end
  end
end