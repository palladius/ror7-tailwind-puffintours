// copied from Bard

// export default function fetchApiData() {
//     // Your fetch API code here
//   }


const fetchApiData = async () => {
    const myPlaceholder = document.getElementById('my-placeholder');
    const apiUrl = "https://reqres.in/api/products/2";
    // Fetch the text from the API
    my_fetch = fetch(apiUrl)
        .then(response => response.json())
        .then(data => {
            console.log("data has come! LEts see tem Riccardo");
            //console.log(data.data.name);

            // Substitute the text from the placeholder with the retrieved text
            myPlaceholder.textContent = "✅ Beh, intanto JS funge 5: " + data.data.name;
            //myPlaceholder.textContent += data.data.name;
            //        myPlaceholder.textContent = data.my_payload;
        }); //.catch((error) => {
    //console.log(error);
    //});
}

document.addEventListener('DOMContentLoaded', fetchApiData);

