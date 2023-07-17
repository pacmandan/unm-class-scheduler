import { connect } from 'react-redux';
import SectionTag from './SectionTag'
import { Section } from './catalog';
import { RootState } from './store';

const mapStateToProps = (state: RootState) => ({sections: state.search.results})

const SearchResults = ({sections}: {sections: Section[]}) => {
  return (<div className="w-96">
    <button className="float-left">Prev</button>
    <button className="float-right">Next</button>
    <table>
      <tbody>
        {sections.map(function(section) {
          return (<tr key={section.crn}><td className='bg-white border-black border-solid border-2'><input type='checkbox'/></td><td><SectionTag section={section} /></td></tr>)
        })}
      </tbody>
    </table>
  </div>)
}

export default connect(mapStateToProps)(SearchResults);