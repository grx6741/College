var sem5_courses = [
    {
	name: "CSE 311 ARTIFICIAL INTELLIGENCE",
	link: "https://lms.iiitkottayam.ac.in/course/view.php?id=370"
    },
    {
	name: "CSE 312 SOFTWARE ENGINEERING AND PROJECT MANAGEMENT",
	link: "https://lms.iiitkottayam.ac.in/course/view.php?id=373"
    },
    {
	name: "ICS 311 PARALLEL AND DISTRIBUTED COMPUTING",
	link: "https://lms.iiitkottayam.ac.in/course/view.php?id=376"
    },
    {
	name: "IEC 311 DIGITAL SIGNAL PROCESSING",
	link: "https://lms.iiitkottayam.ac.in/course/view.php?id=379"
    },
    {
	name: "IHS 311 HUMAN RESOURCE MANAGEMENT",
	link: "https://lms.iiitkottayam.ac.in/course/view.php?id=382"
    },
    {
	name: "IHS 312 FINANCIAL MANAGEMENT & ACCOUNTING",
	link: "https://lms.iiitkottayam.ac.in/course/view.php?id=386"
    },
    {
	name: "IHS 313 OPERATIONS & SUPPLY CHAIN MANAGEMENT",
	link: "https://lms.iiitkottayam.ac.in/course/view.php?id=389"
    },
    {
	name: "IMA 311 SOFT COMPUTING",
	link: "https://lms.iiitkottayam.ac.in/course/view.php?id=367"
    },
]

var semesters = {
    5 : sem5_courses
}


link_container = document.getElementById("link-container");
console.log(link_container);

for (let sem in semesters) {
    for (let course of semesters[sem]) {
	const course_button = document.createElement("button");

	course_button.innerText = course.name;
	course_button.classList.add("link-button");

	course_button.onclick = () => {
	    window.location.href = course.link;
	}

	console.log(course_button);
	link_container.appendChild(course_button);
    }
}
