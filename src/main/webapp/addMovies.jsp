<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<script src="addMovies.js"></script>


<div class="max-w-2xl mx-auto p-6">
  <div class="bg-white rounded-xl shadow-lg p-8">
    <h2 class="mb-6 text-3xl font-bold font-heading text-gray-900">Add Movie</h2>
    <form class="space-y-6" action="AddMoviesServlet" method="post" enctype="multipart/form-data">
     
      <div>
        <label class="block mb-2 text-gray-900 font-semibold leading-normal">Movie Title</label>
        <input class="px-4 py-3.5 w-full text-gray-400 font-medium placeholder-gray-400 bg-white outline-none border border-gray-300 rounded-lg focus:ring focus:ring-indigo-300" name="title" type="text" required placeholder="Enter movie title"/>
      </div>
      
          
	<div>
	  <label class="block mb-2 text-gray-900 font-semibold leading-normal">Status</label>
	  <select class="px-4 py-3.5 w-full text-gray-700 font-medium bg-white outline-none border border-gray-300 rounded-lg focus:ring focus:ring-indigo-300" name="status" >
	    <option value="now-showing" selected>Now Showing</option>
	    <option value="coming-soon">Coming Soon</option>
	  </select>
	</div>

      
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block mb-2 text-gray-900 font-semibold leading-normal">Duration</label>
          <input class="px-4 py-3.5 w-full text-gray-400 font-medium placeholder-gray-400 bg-white outline-none border border-gray-300 rounded-lg focus:ring focus:ring-indigo-300" type="text" placeholder="e.g., 2h30min" name="duration" required/>
        </div>
        <div>
          <label class="block mb-2 text-gray-900 font-semibold leading-normal">Director</label>
          <input class="px-4 py-3.5 w-full text-gray-400 font-medium placeholder-gray-400 bg-white outline-none border border-gray-300 rounded-lg focus:ring focus:ring-indigo-300" type="text" placeholder="Enter director name" name="director" required/>
        </div>
      </div>
      
      
      <div>
        <label class="block mb-2 text-gray-900 font-semibold leading-normal">Cast Members</label>
        <textarea class="p-4 w-full h-32 font-medium text-gray-500 placeholder-gray-500 bg-white bg-opacity-50 outline-none border border-gray-300 resize-none rounded-lg focus:ring focus:ring-indigo-300" placeholder="Enter cast members separated by commas" name="casts" required></textarea>
      </div>
      
      
      <div>
        <label class="block mb-2 text-gray-900 font-semibold leading-normal">Genres</label>
        <input class="px-4 py-3.5 w-full text-gray-400 font-medium placeholder-gray-400 bg-white outline-none border border-gray-300 rounded-lg focus:ring focus:ring-indigo-300" type="text" placeholder="Enter Genre" name="genres" required/>
        </div>
      
      
      <div>
        <label class="block mb-2 text-gray-900 font-semibold leading-normal">Synopsis</label>
        <textarea class="p-4 w-full h-32 font-medium text-gray-500 placeholder-gray-500 bg-white bg-opacity-50 outline-none border border-gray-300 resize-none rounded-lg focus:ring focus:ring-indigo-300" placeholder="Enter Synopsis" name="synopsis" required></textarea>
      </div>
  


	<div>
	  <label class="block mb-2 text-gray-900 font-semibold leading-normal">Movie Poster</label>
	  <div class="flex items-center space-x-4">
	    <div class="flex-1">
	      <input class="poster-input px-4 py-3.5 w-full text-gray-400 font-medium placeholder-gray-400 bg-white outline-none border border-gray-300 rounded-lg focus:ring focus:ring-indigo-300" type="file" name="poster" required/>
	    </div>
	  </div>
	</div>

      <div>
        <label class="block mb-2 text-gray-900 font-semibold leading-normal">Trailer</label>
        <div class="flex items-center space-x-4">
          <div class="flex-1">
            <input class="poster-input px-4 py-3.5 w-full text-gray-400 font-medium placeholder-gray-400 bg-white outline-none border border-gray-300 rounded-lg focus:ring focus:ring-indigo-300" type="file" name="trailer" required/>
          </div>
        </div>
      </div>
      
      
      <div class="pt-4">
        <div class="md:inline-block w-full md:w-auto">
          <button class="py-4 px-6 w-full text-white font-semibold border border-indigo-700 rounded-xl shadow-4xl focus:ring focus:ring-indigo-300 bg-indigo-600 hover:bg-indigo-700 transition ease-in-out duration-200" type="submit">Add Movie</button>
        </div>
      </div>
      </form>
      </div>
   
   
  </div>
 